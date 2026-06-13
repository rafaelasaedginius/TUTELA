import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tutela/models/geo_location_model.dart';

// Google Geocoding docs    : https://developers.google.com/maps/documentation/geocoding
// Google Places (New) docs : https://developers.google.com/maps/documentation/places/web-service/op-overview
// Google Routes docs       : https://developers.google.com/maps/documentation/routes

class MapsService {
  static const _geocoding = 'https://maps.googleapis.com/maps/api/geocode/json';
  static const _placesNew = 'https://places.googleapis.com/v1/places';
  static const _routes = 'https://routes.googleapis.com/directions/v2:computeRoutes';

  String get _apiKey => dotenv.env['GOOGLE_MAPS_KEY'] ?? '';

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

  Future<String?> reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse(_geocoding).replace(queryParameters: {
      'latlng': '$lat,$lng',
      'key': _apiKey,
      'language': 'id',
    });
    final response = await http.get(uri);
    _assertOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _assertGoogleStatus(data);
    final results = data['results'] as List? ?? [];
    if (results.isEmpty) return null;
    return (results.first as Map<String, dynamic>)['formatted_address']
        as String?;
  }

  // ── Geocode (address → coordinates) ──────────────────────────────────────

  Future<GeoLocation?> geocode(String address) async {
    final uri = Uri.parse(_geocoding).replace(queryParameters: {
      'address': address,
      'key': _apiKey,
      'language': 'en',
    });
    final response = await http.get(uri);
    _assertOk(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _assertGoogleStatus(data);
    final results = data['results'] as List? ?? [];
    if (results.isEmpty) return null;
    final first = results.first as Map<String, dynamic>;
    final loc = (first['geometry'] as Map)['location'] as Map;
    return GeoLocation(
      latitude: (loc['lat'] as num).toDouble(),
      longitude: (loc['lng'] as num).toDouble(),
      address: first['formatted_address'] as String?,
    );
  }

  // ── Routing (origin → waypoints → destination) ────────────────────────────
  // Routes API (new): POST with JSON body, key in header, field mask required.

  Future<List<GeoLocation>> getRoute({
    required GeoLocation origin,
    required GeoLocation destination,
    List<GeoLocation> waypoints = const [],
  }) async {
    final body = <String, dynamic>{
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
        },
      },
      'travelMode': 'DRIVE',
      'polylineQuality': 'OVERVIEW',
    };
    if (waypoints.isNotEmpty) {
      body['intermediates'] = waypoints
          .map((p) => {
                'location': {
                  'latLng': {
                    'latitude': p.latitude,
                    'longitude': p.longitude,
                  },
                },
              })
          .toList();
    }

    final response = await http.post(
      Uri.parse(_routes),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
      },
      body: jsonEncode(body),
    );
    _assertOk(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List? ?? [];
    if (routes.isEmpty) throw Exception('No route found');
    final encoded =
        (routes[0] as Map)['polyline']['encodedPolyline'] as String;
    return _decodePolyline(encoded);
  }

  // ── Multiple routes with optional alternatives ───────────────────────────
  // Returns each route as a decoded polyline list; index 0 is the primary route.

  Future<List<List<GeoLocation>>> getRoutes({
    required GeoLocation origin,
    required GeoLocation destination,
    bool computeAlternatives = false,
  }) async {
    final body = <String, dynamic>{
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
        },
      },
      'travelMode': 'DRIVE',
      'polylineQuality': 'OVERVIEW',
      if (computeAlternatives) 'computeAlternativeRoutes': true,
    };

    final response = await http.post(
      Uri.parse(_routes),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'routes.polyline.encodedPolyline',
      },
      body: jsonEncode(body),
    );
    _assertOk(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List? ?? [];
    if (routes.isEmpty) throw Exception('No route found');

    return routes.map<List<GeoLocation>>((r) {
      final encoded =
          (r as Map)['polyline']['encodedPolyline'] as String;
      return _decodePolyline(encoded);
    }).toList();
  }

  // ── Nearby search ─────────────────────────────────────────────────────────
  // Places API (new): POST, key in header, field mask required.
  // amenityType must be a valid Places type e.g. "hospital", "police", "fire_station".

  Future<List<Map<String, dynamic>>> searchNearby({
    required GeoLocation location,
    required double radiusMeters,
    String? amenityType,
  }) async {
    final body = <String, dynamic>{
      'locationRestriction': {
        'circle': {
          'center': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
          'radius': radiusMeters,
        },
      },
      'languageCode': 'id',
    };
    if (amenityType != null && amenityType.trim().isNotEmpty) {
      body['includedTypes'] = [amenityType.trim()];
    }

    final response = await http.post(
      Uri.parse('$_placesNew:searchNearby'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.location,places.formattedAddress',
      },
      body: jsonEncode(body),
    );
    _assertOk(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = <Map<String, dynamic>>[];
    for (final place in (data['places'] as List? ?? [])) {
      final loc = place['location'] as Map;
      results.add({
        'name': (place['displayName'] as Map?)?['text'] ?? 'Unnamed Place',
        'latitude': (loc['latitude'] as num).toDouble(),
        'longitude': (loc['longitude'] as num).toDouble(),
        'formatted_address': place['formattedAddress'],
        'place_id': place['id'],
      });
    }
    return results;
  }

  // ── Places text search ────────────────────────────────────────────────────
  // Places API (new): POST, key in header, field mask required.

  Future<List<Map<String, dynamic>>> searchPlaces(
    String query, {
    GeoLocation? biasLocation,
  }) async {
    final body = <String, dynamic>{
      'textQuery': query,
      'languageCode': 'id',
    };
    if (biasLocation != null) {
      body['locationBias'] = {
        'circle': {
          'center': {
            'latitude': biasLocation.latitude,
            'longitude': biasLocation.longitude,
          },
          'radius': 50000.0,
        },
      };
    }

    final response = await http.post(
      Uri.parse('$_placesNew:searchText'),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask':
            'places.id,places.displayName,places.location,places.formattedAddress',
      },
      body: jsonEncode(body),
    );
    _assertOk(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = <Map<String, dynamic>>[];
    for (final place in (data['places'] as List? ?? [])) {
      final loc = place['location'] as Map;
      results.add({
        'name': (place['displayName'] as Map?)?['text'],
        'formatted_address': place['formattedAddress'],
        'latitude': (loc['latitude'] as num).toDouble(),
        'longitude': (loc['longitude'] as num).toDouble(),
        'place_id': place['id'],
      });
    }
    return results;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _assertOk(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  // Google APIs always return HTTP 200; errors appear in the status field.
  void _assertGoogleStatus(Map<String, dynamic> data) {
    final status = data['status'] as String?;
    if (status == null || status == 'OK' || status == 'ZERO_RESULTS') return;
    final msg = data['error_message'] as String? ?? status;
    throw Exception('Google API: $msg');
  }

  // Decodes a Google Maps encoded polyline into a list of coordinates.
  List<GeoLocation> _decodePolyline(String encoded) {
    final points = <GeoLocation>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b = 0, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      b = 0; shift = 0; result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(GeoLocation(latitude: lat / 1e5, longitude: lng / 1e5));
    }
    return points;
  }
}
