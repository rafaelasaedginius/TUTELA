import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tutela/models/geo_location_model.dart';

// Nominatim docs : https://nominatim.org/release-docs/latest/api/Overview/
// OSRM docs      : https://project-osrm.org/docs/v5.24.0/api/
// Overpass docs  : https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide

class MapsService {
  static const _nominatim = 'https://nominatim.openstreetmap.org';
  static const _osrm = 'https://router.project-osrm.org';
  static const _overpass = 'https://overpass.kumi.systems/api/interpreter';

  // Nominatim requires a descriptive User-Agent header.
  static const _headers = {'User-Agent': 'Tutela/1.0'};

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
  // Nominatim /reverse

  Future<String?> reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse('$_nominatim/reverse').replace(
      queryParameters: {'lat': '$lat', 'lon': '$lng', 'format': 'json'},
    );

    final response = await http.get(uri, headers: _headers);
    _assertOk(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['display_name'] as String?;
  }

  // ── Geocode (address → coordinates) ──────────────────────────────────────
  // Nominatim /search

  Future<GeoLocation?> geocode(String address) async {
    final uri = Uri.parse('$_nominatim/search').replace(
      queryParameters: {'q': address, 'format': 'json', 'limit': '1'},
    );

    final response = await http.get(uri, headers: _headers);
    _assertOk(response);

    final results = jsonDecode(response.body) as List;
    if (results.isEmpty) return null;

    final first = results.first as Map<String, dynamic>;
    return GeoLocation(
      latitude: double.parse(first['lat'] as String),
      longitude: double.parse(first['lon'] as String),
      address: first['display_name'] as String?,
    );
  }

  // ── Routing (origin → waypoints → destination) ────────────────────────────
  // OSRM /route/v1/driving
  // Returns the full route geometry as a list of GeoLocations.
  // Note: OSRM expects coordinates in lon,lat order (opposite of Google Maps).

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

    // GeoJSON coordinates are [longitude, latitude]
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

  // ── Nearby search (radius-based POI) ─────────────────────────────────────
  // Overpass API — returns OSM nodes within radiusMeters.
  // keyword filters by node name (case-insensitive); omit for all amenities.

  Future<List<Map<String, dynamic>>> searchNearby({
    required GeoLocation location,
    required double radiusMeters,
    String? keyword,
  }) async {
    final filter = keyword != null
        ? '[name~"$keyword",i]'
        : '["amenity"~"police|hospital|fire_station|pharmacy|clinic"]';
    final query =
        '[out:json][timeout:25];node(around:$radiusMeters,${location.latitude},${location.longitude})$filter;out body 50;';

    final uri = Uri.parse(_overpass).replace(queryParameters: {'data': query});
    final response = await http.get(uri, headers: _headers);
    _assertOk(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['elements'] ?? []);
  }

  // ── Places text search ────────────────────────────────────────────────────
  // Nominatim /search with optional location bias via viewbox.

  Future<List<Map<String, dynamic>>> searchPlaces(
    String query, {
    GeoLocation? biasLocation,
  }) async {
    final params = <String, String>{
      'q': query,
      'format': 'json',
      'limit': '10',
      'addressdetails': '1',
    };

    if (biasLocation != null) {
      // ~55 km viewbox centred on biasLocation; bounded=0 still returns
      // results outside the box if nothing matches inside it.
      const d = 0.5;
      params['viewbox'] =
          '${biasLocation.longitude - d},${biasLocation.latitude + d},'
          '${biasLocation.longitude + d},${biasLocation.latitude - d}';
      params['bounded'] = '0';
    }

    final uri =
        Uri.parse('$_nominatim/search').replace(queryParameters: params);

    final response = await http.get(uri, headers: _headers);
    _assertOk(response);

    return List<Map<String, dynamic>>.from(
      jsonDecode(response.body) as List,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _assertOk(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}
