import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tutela/models/geo_location_model.dart';

// MapTiler geocoding docs : https://docs.maptiler.com/cloud/api/geocoding/
// OSRM routing docs       : https://project-osrm.org/docs/v5.24.0/api/

class MapsService {
  static const _maptiler = 'https://api.maptiler.com/geocoding';
  static const _osrm = 'https://router.project-osrm.org';

  String get _apiKey => dotenv.env['MAPTILER_KEY'] ?? '';

  // ── Current location ────────────────────────────────────────────────────────

  Future<GeoLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied.');
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    final address = await reverseGeocode(pos.latitude, pos.longitude);
    return GeoLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      address: address,
      accuracyMeters: pos.accuracy,
    );
  }

  // ── Reverse geocode (coordinates → address) ──────────────────────────────
  // MapTiler /geocoding/{lon},{lat}.json

  Future<String?> reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse('$_maptiler/$lng,$lat.json').replace(
      queryParameters: {'key': _apiKey, 'language': 'en'},
    );
    final response = await http.get(uri);
    _assertOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List? ?? [];
    if (features.isEmpty) return null;
    return (features.first as Map<String, dynamic>)['place_name'] as String?;
  }

  // ── Geocode (address → coordinates) ──────────────────────────────────────
  // MapTiler /geocoding/{query}.json

  Future<GeoLocation?> geocode(String address) async {
    final uri =
        Uri.parse('$_maptiler/${Uri.encodeComponent(address)}.json').replace(
      queryParameters: {'key': _apiKey, 'limit': '1', 'language': 'en'},
    );
    final response = await http.get(uri);
    _assertOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final features = data['features'] as List? ?? [];
    if (features.isEmpty) return null;
    final first = features.first as Map<String, dynamic>;
    final coords = (first['geometry'] as Map)['coordinates'] as List;
    return GeoLocation(
      latitude: (coords[1] as num).toDouble(),
      longitude: (coords[0] as num).toDouble(),
      address: first['place_name'] as String?,
    );
  }

  // ── Routing (origin → waypoints → destination) ────────────────────────────
  // OSRM /route/v1/driving — coordinates must be in lon,lat order.

  Future<List<GeoLocation>> getRoute({
    required GeoLocation origin,
    required GeoLocation destination,
    List<GeoLocation> waypoints = const [],
  }) async {
    final allPoints = [origin, ...waypoints, destination];
    final coords =
        allPoints.map((p) => '${p.longitude},${p.latitude}').join(';');

    final uri = Uri.parse('$_osrm/route/v1/driving/$coords').replace(
      queryParameters: {'overview': 'full', 'geometries': 'geojson'},
    );

    final response = await http.get(uri);
    _assertOk(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['code'] != 'Ok') {
      throw Exception('OSRM error: ${data['code']}');
    }

    final coordinates =
        data['routes'][0]['geometry']['coordinates'] as List;
    return coordinates.map((c) {
      final coord = c as List;
      return GeoLocation(
        latitude: (coord[1] as num).toDouble(),
        longitude: (coord[0] as num).toDouble(),
      );
    }).toList();
  }

  // ── Nearby search (proximity-biased POI) ──────────────────────────────────
  // MapTiler geocoding with proximity — returns results sorted by distance.
  // Note: MapTiler does not support strict radius filtering; radiusMeters is
  // stored for future use when a radius-capable API is available.

  Future<List<Map<String, dynamic>>> searchNearby({
    required GeoLocation location,
    required double radiusMeters,
    String? keyword,
  }) async {
    final q = keyword ?? 'police hospital clinic fire_station';
    final uri =
        Uri.parse('$_maptiler/${Uri.encodeComponent(q)}.json').replace(
      queryParameters: {
        'key': _apiKey,
        'proximity': '${location.longitude},${location.latitude}',
        'limit': '10',
        'language': 'en',
      },
    );
    final response = await http.get(uri);
    _assertOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['features'] ?? []);
  }

  // ── Places text search ────────────────────────────────────────────────────
  // MapTiler geocoding with optional proximity bias.

  Future<List<Map<String, dynamic>>> searchPlaces(
    String query, {
    GeoLocation? biasLocation,
  }) async {
    final params = <String, String>{
      'key': _apiKey,
      'limit': '10',
      'language': 'en',
    };
    if (biasLocation != null) {
      params['proximity'] =
          '${biasLocation.longitude},${biasLocation.latitude}';
    }

    final uri =
        Uri.parse('$_maptiler/${Uri.encodeComponent(query)}.json').replace(
      queryParameters: params,
    );

    final response = await http.get(uri);
    _assertOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['features'] ?? []);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _assertOk(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
