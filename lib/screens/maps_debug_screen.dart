import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tutela/models/geo_location_model.dart';
import 'package:tutela/services/maps_service.dart';
import 'package:tutela/theme/tutela_colors.dart';

typedef _State = ({bool loading, String? result, String? error});

class MapsDebugScreen extends StatefulWidget {
  const MapsDebugScreen({super.key});

  @override
  State<MapsDebugScreen> createState() => _MapsDebugScreenState();
}

class _MapsDebugScreenState extends State<MapsDebugScreen> {
  final _service = MapsService();
  final _mapController = MapController();
  final Map<String, _State> _states = {};

  static const _monas = LatLng(-6.1751, 106.8272);

  LatLng? _currentPin;
  List<LatLng> _nearbyPins = [];
  List<LatLng> _routeLine = [];

  // Pre-filled with Monas & Bundaran HI (Jakarta)
  final _revLatC  = TextEditingController(text: '-6.1751');
  final _revLonC  = TextEditingController(text: '106.8272');
  final _geoAddrC = TextEditingController(text: 'Monas, Jakarta');
  final _origLatC = TextEditingController(text: '-6.1751');
  final _origLonC = TextEditingController(text: '106.8272');
  final _destLatC = TextEditingController(text: '-6.1944');
  final _destLonC = TextEditingController(text: '106.8229');
  final _nearLatC = TextEditingController(text: '-6.1751');
  final _nearLonC = TextEditingController(text: '106.8272');
  final _nearRadC = TextEditingController(text: '500');
  final _nearKwC  = TextEditingController();
  final _placeQC  = TextEditingController(text: 'polisi Jakarta');

  @override
  void dispose() {
    for (final c in [
      _revLatC, _revLonC, _geoAddrC, _origLatC, _origLonC,
      _destLatC, _destLonC, _nearLatC, _nearLonC, _nearRadC, _nearKwC, _placeQC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(String key, Future<String> Function() fn) async {
    setState(() => _states[key] = (loading: true, result: null, error: null));
    try {
      final result = await fn();
      setState(() => _states[key] = (loading: false, result: result, error: null));
    } catch (e) {
      setState(() => _states[key] = (loading: false, result: null, error: e.toString()));
    }
  }

  void _moveMap(LatLng center, {double zoom = 14}) {
    _mapController.move(center, zoom);
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = dotenv.env['MAPTILER_KEY'] ?? '';

    return Scaffold(
      backgroundColor: TutelaColors.ivory,
      appBar: AppBar(
        backgroundColor: TutelaColors.plum,
        foregroundColor: TutelaColors.canvas,
        title: Text(
          'Maps Service Test',
          style: GoogleFonts.dmSans(
            color: TutelaColors.canvas,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Live map ──────────────────────────────────────────────────────
          _MapCard(
            apiKey: apiKey,
            mapController: _mapController,
            currentPin: _currentPin,
            nearbyPins: _nearbyPins,
            routeLine: _routeLine,
          ),
          const SizedBox(height: 14),

          // ── getCurrentLocation ────────────────────────────────────────────
          _SectionCard(
            title: 'getCurrentLocation',
            icon: Icons.my_location_rounded,
            state: _states['location'],
            onTest: () => _run('location', () async {
              final loc = await _service.getCurrentLocation();
              final pin = LatLng(loc.latitude, loc.longitude);
              setState(() => _currentPin = pin);
              _moveMap(pin, zoom: 15);
              return 'lat: ${loc.latitude}\n'
                  'lon: ${loc.longitude}\n'
                  'address: ${loc.address ?? '—'}\n'
                  'accuracy: ${loc.accuracyMeters?.toStringAsFixed(1) ?? '—'} m';
            }),
          ),

          // ── reverseGeocode ────────────────────────────────────────────────
          _SectionCard(
            title: 'reverseGeocode',
            icon: Icons.pin_drop_outlined,
            state: _states['reverse'],
            fields: [
              _row([_field('Latitude', _revLatC), _field('Longitude', _revLonC)]),
            ],
            onTest: () => _run('reverse', () async {
              final lat = double.parse(_revLatC.text.trim());
              final lon = double.parse(_revLonC.text.trim());
              _moveMap(LatLng(lat, lon));
              return await _service.reverseGeocode(lat, lon) ?? 'No result';
            }),
          ),

          // ── geocode ───────────────────────────────────────────────────────
          _SectionCard(
            title: 'geocode',
            icon: Icons.search_rounded,
            state: _states['geocode'],
            fields: [_field('Address', _geoAddrC)],
            onTest: () => _run('geocode', () async {
              final loc = await _service.geocode(_geoAddrC.text.trim());
              if (loc == null) return 'No result';
              _moveMap(LatLng(loc.latitude, loc.longitude));
              return 'lat: ${loc.latitude}\n'
                  'lon: ${loc.longitude}\n'
                  'address: ${loc.address ?? '—'}';
            }),
          ),

          // ── getRoute ──────────────────────────────────────────────────────
          _SectionCard(
            title: 'getRoute',
            icon: Icons.route_outlined,
            state: _states['route'],
            fields: [
              _row([_field('Origin lat', _origLatC), _field('Origin lon', _origLonC)]),
              const SizedBox(height: 8),
              _row([_field('Dest lat', _destLatC), _field('Dest lon', _destLonC)]),
            ],
            onTest: () => _run('route', () async {
              final origin = GeoLocation(
                latitude: double.parse(_origLatC.text.trim()),
                longitude: double.parse(_origLonC.text.trim()),
              );
              final dest = GeoLocation(
                latitude: double.parse(_destLatC.text.trim()),
                longitude: double.parse(_destLonC.text.trim()),
              );
              final pts = await _service.getRoute(origin: origin, destination: dest);
              setState(() {
                _routeLine = pts.map((p) => LatLng(p.latitude, p.longitude)).toList();
              });
              if (_routeLine.isNotEmpty) _moveMap(_routeLine.first, zoom: 13);
              return '${pts.length} route points\n'
                  'First: ${pts.first.latitude}, ${pts.first.longitude}\n'
                  'Last:  ${pts.last.latitude}, ${pts.last.longitude}';
            }),
          ),

          // ── searchNearby ──────────────────────────────────────────────────
          _SectionCard(
            title: 'searchNearby',
            icon: Icons.radar_rounded,
            state: _states['nearby'],
            fields: [
              _row([
                _field('Lat', _nearLatC),
                _field('Lon', _nearLonC),
                _field('Radius (m)', _nearRadC),
              ]),
              const SizedBox(height: 8),
              _field('Keyword (optional)', _nearKwC),
            ],
            onTest: () => _run('nearby', () async {
              final loc = GeoLocation(
                latitude: double.parse(_nearLatC.text.trim()),
                longitude: double.parse(_nearLonC.text.trim()),
              );
              final kw = _nearKwC.text.trim();
              final results = await _service.searchNearby(
                location: loc,
                radiusMeters: double.parse(_nearRadC.text.trim()),
                keyword: kw.isEmpty ? null : kw,
              );
              setState(() {
                _nearbyPins = results
                    .map((r) {
                      final coords =
                          (r['geometry']?['coordinates'] as List?) ?? [];
                      if (coords.length < 2) return null;
                      return LatLng(
                        (coords[1] as num).toDouble(),
                        (coords[0] as num).toDouble(),
                      );
                    })
                    .whereType<LatLng>()
                    .toList();
              });
              if (_nearbyPins.isNotEmpty) _moveMap(_nearbyPins.first, zoom: 14);
              if (results.isEmpty) return 'No results';
              final first = results.first;
              final name = first['place_name'] ?? first['text'] ?? '—';
              final coords = (first['geometry']?['coordinates'] as List?) ?? [];
              final lat = coords.length >= 2 ? coords[1] : '—';
              final lon = coords.length >= 2 ? coords[0] : '—';
              return '${results.length} results\n'
                  'First: $name\n'
                  'At: $lat, $lon';
            }),
          ),

          // ── searchPlaces ──────────────────────────────────────────────────
          _SectionCard(
            title: 'searchPlaces',
            icon: Icons.place_outlined,
            state: _states['places'],
            fields: [_field('Query', _placeQC)],
            onTest: () => _run('places', () async {
              final results =
                  await _service.searchPlaces(_placeQC.text.trim());
              if (results.isEmpty) return 'No results';
              return '${results.length} results\n'
                  'First: ${results.first['place_name'] ?? '—'}';
            }),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: GoogleFonts.dmSans(fontSize: 13, color: TutelaColors.plum),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 12,
          color: TutelaColors.plum.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: TutelaColors.ivory,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: TutelaColors.plum.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: TutelaColors.plum.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: TutelaColors.plum),
        ),
      ),
    );
  }

  Widget _row(List<Widget> children) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

// ── Map card ───────────────────────────────────────────────────────────────────

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.apiKey,
    required this.mapController,
    required this.currentPin,
    required this.nearbyPins,
    required this.routeLine,
  });

  static const _monas = LatLng(-6.1751, 106.8272);

  final String apiKey;
  final MapController mapController;
  final LatLng? currentPin;
  final List<LatLng> nearbyPins;
  final List<LatLng> routeLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: _monas,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$apiKey',
              userAgentPackageName: 'com.tutela.app',
            ),
            if (routeLine.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeLine,
                    color: TutelaColors.plum,
                    strokeWidth: 4,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (currentPin != null)
                  Marker(
                    point: currentPin!,
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                ...nearbyPins.map(
                  (p) => Marker(
                    point: p,
                    width: 30,
                    height: 30,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            // legend
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location_rounded,
                        color: Colors.blue, size: 13),
                    const SizedBox(width: 4),
                    Text('Me',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: TutelaColors.plum)),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on,
                        color: Colors.red, size: 13),
                    const SizedBox(width: 4),
                    Text('Nearby',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: TutelaColors.plum)),
                    const SizedBox(width: 10),
                    Container(
                        width: 16,
                        height: 3,
                        color: TutelaColors.plum),
                    const SizedBox(width: 4),
                    Text('Route',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: TutelaColors.plum)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section card ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.onTest,
    this.state,
    this.fields = const [],
  });

  final String title;
  final IconData icon;
  final VoidCallback onTest;
  final _State? state;
  final List<Widget> fields;

  @override
  Widget build(BuildContext context) {
    final busy = state?.loading == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TutelaColors.canvas,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: TutelaColors.plum, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.plum,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (fields.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...fields,
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: busy ? null : onTest,
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: busy
                    ? TutelaColors.plum.withValues(alpha: 0.5)
                    : TutelaColors.plum,
                borderRadius: BorderRadius.circular(21),
              ),
              alignment: Alignment.center,
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TutelaColors.canvas,
                      ),
                    )
                  : Text(
                      'Run test',
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.canvas,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
            ),
          ),
          if (state?.result != null) ...[
            const SizedBox(height: 12),
            _ResultBox(text: state!.result!, isError: false),
          ],
          if (state?.error != null) ...[
            const SizedBox(height: 12),
            _ResultBox(text: state!.error!, isError: true),
          ],
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  const _ResultBox({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF0F0) : TutelaColors.ivory,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? const Color(0xFFFFCDD2)
              : TutelaColors.plum.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12.5,
          color: isError ? const Color(0xFFB71C1C) : TutelaColors.plum,
          height: 1.5,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
