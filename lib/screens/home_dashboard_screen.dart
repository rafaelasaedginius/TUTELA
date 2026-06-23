import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/geo_location_model.dart';
import '../models/incident_model.dart';
import '../models/safe_route_model.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/emergency_contact_service.dart';
import '../services/incident_service.dart';
import '../services/maps_service.dart';
import '../services/safe_route_service.dart';
import '../services/user_service.dart';
import '../theme/tutela_colors.dart';
import 'report_incident_screen.dart';
import '../widgets/tutela_bottom_nav.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final _incidentService = IncidentService();
  final _routeService = SafeRouteService();
  final _mapsService = MapsService();
  final _userService = UserService();
  final _mapController = MapController();
  final _user = fb.FirebaseAuth.instance.currentUser;
  String _username = '';

  // Location
  GeoLocation? _currentLocation;
  bool _isLocating = false;

  // Incidents & saved routes (for background proximity warnings)
  List<Incident> _incidents = [];
  List<SafeRoute> _myRoutes = [];
  List<SafeRoute> _warnedRoutes = [];

  // Active route search
  GeoLocation? _searchedDestination;
  String? _destinationLabel;
  List<GeoLocation>? _mainRoute;
  List<GeoLocation>? _altRoute;
  bool _isRouting = false;
  List<Incident> _mainRouteIncidents = [];
  List<Incident> _altRouteIncidents = [];

  StreamSubscription<List<Incident>>? _incidentSub;
  StreamSubscription<List<SafeRoute>>? _routeSub;

  static const _warningRadiusM = 500.0;
  static const _defaultCenter = LatLng(-6.2088, 106.8456);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _incidentSub = _incidentService.streamActiveIncidents().listen(
      (incidents) {
        setState(() => _incidents = incidents);
        _computeWarnings();
        if (_mainRoute != null) _recomputeRouteIncidents();
      },
      onError: (_) {},
    );
    final uid = _user?.uid;
    if (uid != null) {
      _routeSub = _routeService.streamMyRoutes(uid).listen(
        (routes) {
          setState(() => _myRoutes = routes);
          _computeWarnings();
        },
        onError: (_) {},
      );
    }
    // Auto-locate after first frame so MapController is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoLocate());
  }

  @override
  void dispose() {
    _incidentSub?.cancel();
    _routeSub?.cancel();
    super.dispose();
  }

  // ── Username ──────────────────────────────────────────────────────────────

  Future<void> _loadUsername() async {
    final uid = _user?.uid;
    if (uid == null) return;
    try {
      final profile = await _userService.getUser(uid);
      if (!mounted) return;
      final name = profile?.name.trim() ?? '';
      setState(() => _username = name.isNotEmpty ? name.split(' ').first : 'User');
    } catch (_) {
      if (mounted) setState(() => _username = 'User');
    }
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _autoLocate() async {
    try {
      final loc = await _mapsService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _currentLocation = loc);
      _mapController.move(LatLng(loc.latitude, loc.longitude), 14);
    } catch (_) {
      // Silent — user can tap the location button to retry
    }
  }

  Future<void> _refreshLocation() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    try {
      final loc = await _mapsService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _currentLocation = loc);
      _mapController.move(LatLng(loc.latitude, loc.longitude), 15);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not get location: $e'),
          backgroundColor: TutelaColors.plum,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // ── Saved-route proximity warnings ────────────────────────────────────────

  void _computeWarnings() {
    final warned = <SafeRoute>[];
    for (final route in _myRoutes) {
      final a = LatLng(route.origin.latitude, route.origin.longitude);
      final b =
          LatLng(route.destination.latitude, route.destination.longitude);
      for (final incident in _incidents) {
        final p =
            LatLng(incident.location.latitude, incident.location.longitude);
        if (_distToSegmentMeters(p, a, b) <= _warningRadiusM) {
          warned.add(route);
          break;
        }
      }
    }
    setState(() => _warnedRoutes = warned);
  }

  // ── Active route planning ─────────────────────────────────────────────────

  Future<void> _openDestinationSearch() async {
    final result = await showModalBottomSheet<GeoLocation>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _DestinationSearchSheet(mapsService: _mapsService),
    );
    if (result == null || !mounted) return;
    setState(() {
      _searchedDestination = result;
      _destinationLabel = result.address ??
          result.label ??
          '${result.latitude.toStringAsFixed(4)}, '
              '${result.longitude.toStringAsFixed(4)}';
    });
    _planRoute();
  }

  Future<void> _planRoute() async {
    if (_searchedDestination == null) return;

    // Ensure current location is available
    if (_currentLocation == null) {
      setState(() => _isRouting = true);
      try {
        final loc = await _mapsService.getCurrentLocation();
        if (!mounted) return;
        setState(() => _currentLocation = loc);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Enable location permission to plan routes from your position.'),
          ));
          setState(() => _isRouting = false);
        }
        return;
      }
    }

    setState(() {
      _isRouting = true;
      _mainRoute = null;
      _altRoute = null;
      _mainRouteIncidents = [];
      _altRouteIncidents = [];
    });

    try {
      final routes = await _mapsService.getRoutes(
        origin: _currentLocation!,
        destination: _searchedDestination!,
        computeAlternatives: true,
      );
      if (!mounted) return;

      final main = routes[0];
      final alt = routes.length > 1 ? routes[1] : null;

      setState(() {
        _mainRoute = main;
        _altRoute = alt;
        _mainRouteIncidents = _incidentsNearRoute(main);
        _altRouteIncidents =
            alt != null ? _incidentsNearRoute(alt) : [];
        _isRouting = false;
      });

      _mapController.fitCamera(CameraFit.coordinates(
        coordinates:
            main.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        padding: const EdgeInsets.fromLTRB(50, 120, 50, 220),
      ));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not find route: $e')));
        setState(() => _isRouting = false);
      }
    }
  }

  void _recomputeRouteIncidents() {
    if (_mainRoute == null) return;
    setState(() {
      _mainRouteIncidents = _incidentsNearRoute(_mainRoute!);
      if (_altRoute != null) {
        _altRouteIncidents = _incidentsNearRoute(_altRoute!);
      }
    });
  }

  void _switchToAltRoute() {
    final tmpRoute = _mainRoute;
    final tmpInc = _mainRouteIncidents;
    setState(() {
      _mainRoute = _altRoute;
      _altRoute = tmpRoute;
      _mainRouteIncidents = _altRouteIncidents;
      _altRouteIncidents = tmpInc;
    });
  }

  void _clearRoute() {
    setState(() {
      _searchedDestination = null;
      _destinationLabel = null;
      _mainRoute = null;
      _altRoute = null;
      _mainRouteIncidents = [];
      _altRouteIncidents = [];
    });
  }

  List<Incident> _incidentsNearRoute(List<GeoLocation> route) {
    if (route.length < 2) return [];
    return _incidents.where((incident) {
      final p =
          LatLng(incident.location.latitude, incident.location.longitude);
      for (int i = 0; i < route.length - 1; i++) {
        final a = LatLng(route[i].latitude, route[i].longitude);
        final b = LatLng(route[i + 1].latitude, route[i + 1].longitude);
        if (_distToSegmentMeters(p, a, b) <= _warningRadiusM) return true;
      }
      return false;
    }).toList();
  }

  // ── Geometry ──────────────────────────────────────────────────────────────

  static double _distToSegmentMeters(LatLng p, LatLng a, LatLng b) {
    const mPerLat = 111320.0;
    final lat0 = (a.latitude + b.latitude) / 2;
    final mPerLon = 111320.0 * cos(lat0 * pi / 180);
    final ax = a.longitude * mPerLon;
    final ay = a.latitude * mPerLat;
    final bx = b.longitude * mPerLon;
    final by = b.latitude * mPerLat;
    final px = p.longitude * mPerLon;
    final py = p.latitude * mPerLat;
    final dx = bx - ax;
    final dy = by - ay;
    final lenSq = dx * dx + dy * dy;
    final t = lenSq == 0
        ? 0.0
        : ((px - ax) * dx + (py - ay) * dy) / lenSq;
    final tc = t.clamp(0.0, 1.0);
    final diffX = px - (ax + tc * dx);
    final diffY = py - (ay + tc * dy);
    return sqrt(diffX * diffX + diffY * diffY);
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  void _showIncidentSheet(Incident incident) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: incident.category.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(incident.category.icon,
                    color: incident.category.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(incident.title,
                        style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: TutelaColors.plum)),
                    Text(incident.category.label,
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color:
                                TutelaColors.plum.withValues(alpha: 0.55))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: incident.severity.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(incident.severity.label,
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: incident.severity.color)),
              ),
            ]),
            if (incident.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(incident.description,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: TutelaColors.plum.withValues(alpha: 0.72)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  color: TutelaColors.plum, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  incident.location.address ??
                      '${incident.location.latitude.toStringAsFixed(4)}, '
                          '${incident.location.longitude.toStringAsFixed(4)}',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: TutelaColors.plum.withValues(alpha: 0.55)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showRouteIncidentsSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFD96A3A), size: 22),
              const SizedBox(width: 10),
              Text('Incidents Along Route',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TutelaColors.plum)),
            ]),
            const SizedBox(height: 4),
            Text('These incidents are within 500 m of your route:',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: TutelaColors.plum.withValues(alpha: 0.6))),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _mainRouteIncidents.length,
                separatorBuilder: (_, _) =>
                    Divider(color: TutelaColors.plum.withValues(alpha: 0.08)),
                itemBuilder: (_, i) {
                  final inc = _mainRouteIncidents[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: inc.severity.color.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(inc.category.icon,
                            color: inc.severity.color, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(inc.title,
                                style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: TutelaColors.plum)),
                            Text(
                              '${inc.category.label} · ${inc.severity.label}',
                              style: GoogleFonts.dmSans(
                                  fontSize: 11.5,
                                  color: TutelaColors.plum
                                      .withValues(alpha: 0.55)),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
            if (_altRoute != null &&
                _altRouteIncidents.length < _mainRouteIncidents.length) ...[
              const SizedBox(height: 20),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(ctx);
                  _switchToAltRoute();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.alt_route_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _altRouteIncidents.isEmpty
                            ? 'Switch to safer route (no incidents)'
                            : 'Switch to safer route (${_altRouteIncidents.length} fewer incident${_altRouteIncidents.length == 1 ? '' : 's'})',
                        style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showWarningsSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFD96A3A), size: 22),
              const SizedBox(width: 10),
              Text('Route Warnings',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TutelaColors.plum)),
            ]),
            const SizedBox(height: 4),
            Text('Incidents reported within 500 m of your saved routes:',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: TutelaColors.plum.withValues(alpha: 0.6))),
            const SizedBox(height: 16),
            ..._warnedRoutes.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    const Icon(Icons.route_rounded,
                        color: Color(0xFFD96A3A), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: TutelaColors.plum)),
                          Text(
                            '${r.origin.address ?? r.origin.label ?? 'Origin'}'
                            ' → '
                            '${r.destination.address ?? r.destination.label ?? 'Destination'}',
                            style: GoogleFonts.dmSans(
                                fontSize: 11.5,
                                color: TutelaColors.plum
                                    .withValues(alpha: 0.55)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ]),
                )),
          ],
        ),
      ),
    );
  }

  // ── Safety card ───────────────────────────────────────────────────────────

  Widget _buildSafetyCard() {
    // Route is computing
    if (_isRouting) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF337AA8).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(
                  color: Color(0xFF337AA8), strokeWidth: 2.5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Finding your route…',
                  style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TutelaColors.plum)),
              const SizedBox(height: 4),
              Text('Checking for incidents nearby',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: TutelaColors.plum.withValues(alpha: 0.62))),
            ]),
          ),
        ]),
      );
    }

    // Route is planned
    if (_mainRoute != null) {
      final hasIncidents = _mainRouteIncidents.isNotEmpty;
      final canSwitch = _altRoute != null &&
          _altRouteIncidents.length < _mainRouteIncidents.length;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: hasIncidents ? _showRouteIncidentsSheet : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TutelaColors.canvas,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: TutelaColors.plum.withValues(alpha: 0.14),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasIncidents
                        ? const Color(0xFFD96A3A).withValues(alpha: 0.14)
                        : const Color(0xFF2E7D32).withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasIncidents
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                    color: hasIncidents
                        ? const Color(0xFFD96A3A)
                        : const Color(0xFF2E7D32),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasIncidents
                            ? '${_mainRouteIncidents.length} incident${_mainRouteIncidents.length > 1 ? 's' : ''} along route'
                            : 'Route looks safe',
                        style: GoogleFonts.dmSans(
                          color: hasIncidents
                              ? const Color(0xFFD96A3A)
                              : const Color(0xFF2E7D32),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasIncidents
                            ? (canSwitch
                                ? 'Tap to view details & switch route'
                                : 'Tap to view details')
                            : 'No incidents detected nearby',
                        style: GoogleFonts.dmSans(
                          color: TutelaColors.plum.withValues(alpha: 0.62),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasIncidents)
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFFD96A3A)),
              ]),
              // Inline switch-route button when alternative is safer
              if (canSwitch && hasIncidents) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _switchToAltRoute,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.alt_route_rounded,
                            color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _altRouteIncidents.isEmpty
                              ? 'Switch to safer route (no incidents)'
                              : 'Switch to safer route',
                          style: GoogleFonts.dmSans(
                              color: const Color(0xFF2E7D32),
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Default: saved-route warnings
    final hasWarnings = _warnedRoutes.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hasWarnings ? _showWarningsSheet : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasWarnings
                  ? const Color(0xFFD96A3A).withValues(alpha: 0.14)
                  : TutelaColors.peach.withValues(alpha: 0.34),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasWarnings ? Icons.warning_amber_rounded : Icons.shield_outlined,
              color: hasWarnings ? const Color(0xFFD96A3A) : TutelaColors.plum,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                hasWarnings
                    ? '${_warnedRoutes.length} route${_warnedRoutes.length > 1 ? 's' : ''} with nearby incidents'
                    : 'Safer route available',
                style: GoogleFonts.dmSans(
                  color: hasWarnings
                      ? const Color(0xFFD96A3A)
                      : TutelaColors.plum,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hasWarnings
                    ? 'Tap to see affected routes'
                    : 'Low reports nearby',
                style: GoogleFonts.dmSans(
                    color: TutelaColors.plum.withValues(alpha: 0.62),
                    fontSize: 13),
              ),
            ]),
          ),
          if (hasWarnings)
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFD96A3A)),
        ]),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final contentWidth = (size.width - 32).clamp(300.0, 430.0);

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Header
                Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Hi, $_username',
                        style: GoogleFonts.fraunces(
                            color: TutelaColors.plum,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            letterSpacing: 0)),
                    const SizedBox(height: 7),
                    Text('Plan a safer route today.',
                        style: GoogleFonts.dmSans(
                            color: TutelaColors.plum.withValues(alpha: 0.72),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0)),
                  ]),
                  const Spacer(),
                  _IconCircleButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 18),
                // Search bar
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _openDestinationSearch,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: TutelaColors.ivory.withValues(alpha: 0.34),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                          color: TutelaColors.plum.withValues(alpha: 0.12)),
                    ),
                    child: Row(children: [
                      Icon(Icons.search_rounded,
                          color: TutelaColors.plum.withValues(alpha: 0.72),
                          size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _destinationLabel ?? 'Search destination',
                          style: GoogleFonts.dmSans(
                            color: _destinationLabel != null
                                ? TutelaColors.plum
                                : TutelaColors.plum.withValues(alpha: 0.48),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_destinationLabel != null)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _clearRoute,
                          child: Icon(Icons.close_rounded,
                              color: TutelaColors.plum.withValues(alpha: 0.5),
                              size: 18),
                        ),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                // Map + overlaid cards
                Expanded(
                  child: Stack(
                    children: [
                      // Live map
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _defaultCenter,
                              initialZoom: 12,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.tutela.app',
                              ),
                              // Route polylines
                              if (_mainRoute != null || _altRoute != null)
                                PolylineLayer(polylines: [
                                  if (_altRoute != null)
                                    Polyline(
                                      points: _altRoute!
                                          .map((p) =>
                                              LatLng(p.latitude, p.longitude))
                                          .toList(),
                                      color: Colors.grey
                                          .withValues(alpha: 0.45),
                                      strokeWidth: 4,
                                    ),
                                  if (_mainRoute != null)
                                    Polyline(
                                      points: _mainRoute!
                                          .map((p) =>
                                              LatLng(p.latitude, p.longitude))
                                          .toList(),
                                      color: const Color(0xFF337AA8),
                                      strokeWidth: 5,
                                    ),
                                ]),
                              MarkerLayer(markers: [
                                // Current location
                                if (_currentLocation != null)
                                  Marker(
                                    point: LatLng(_currentLocation!.latitude,
                                        _currentLocation!.longitude),
                                    width: 20,
                                    height: 20,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF337AA8),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 3),
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4)
                                        ],
                                      ),
                                    ),
                                  ),
                                // Destination pin
                                if (_searchedDestination != null)
                                  Marker(
                                    point: LatLng(
                                        _searchedDestination!.latitude,
                                        _searchedDestination!.longitude),
                                    width: 36,
                                    height: 36,
                                    child: const Icon(Icons.location_pin,
                                        color: TutelaColors.rose, size: 36),
                                  ),
                                // Incident pins
                                ..._incidents.map(
                                  (incident) => Marker(
                                    point: LatLng(incident.location.latitude,
                                        incident.location.longitude),
                                    width: 34,
                                    height: 34,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showIncidentSheet(incident),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: incident.severity.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2))
                                          ],
                                        ),
                                        child: Icon(incident.category.icon,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),

                      // Map control buttons
                      Positioned(
                        top: 16,
                        right: 14,
                        child: Column(children: [
                          _IconCircleButton(
                            icon: _isLocating
                                ? Icons.hourglass_top_rounded
                                : Icons.my_location_rounded,
                            onTap: _refreshLocation,
                          ),
                          const SizedBox(height: 10),
                          _IconCircleButton(
                            icon: Icons.layers_rounded,
                            onTap: () {},
                          ),
                        ]),
                      ),

                      // Safety / warning card
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 88,
                        child: _buildSafetyCard(),
                      ),

                      // Quick actions
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 18,
                        child: Row(children: [
                          Expanded(
                            child: _DashboardActionButton(
                              label: 'Report',
                              icon: Icons.add_location_alt_outlined,
                              filled: false,
                              onTap: () => _openReportIncident(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashboardActionButton(
                              label: 'SOS',
                              icon: Icons.sos_rounded,
                              filled: true,
                              onTap: () => _triggerSos(context),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const TutelaBottomNav(selected: TutelaNavTab.map),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openReportIncident(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
          builder: (context) => const ReportIncidentScreen()),
    );
  }

  Future<void> _triggerSos(BuildContext context) async {
    // Logic ini sama dengan SOS pada Home: kontak priority pertama dipakai,
    // sedangkan 110 menjadi fallback jika kontak belum tersedia.
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;

    String? phoneNumber;
    if (uid != null) {
      try {
        final contacts = await EmergencyContactService().getContacts(uid);
        if (contacts.isNotEmpty) {
          phoneNumber = contacts.first.phoneNumber;
        }
      } catch (_) {}
    }

    phoneNumber ??= '110';

    final cleaned = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    // Scheme tel: dibuka oleh package url_launcher ke aplikasi Phone.
    final uri = Uri(scheme: 'tel', path: cleaned);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open phone app.')),
      );
    }
  }
}

// ── Destination search sheet ──────────────────────────────────────────────────

class _DestinationSearchSheet extends StatefulWidget {
  const _DestinationSearchSheet({required this.mapsService});
  final MapsService mapsService;

  @override
  State<_DestinationSearchSheet> createState() =>
      _DestinationSearchSheetState();
}

class _DestinationSearchSheetState extends State<_DestinationSearchSheet> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _results = [];
      _isSearching = true;
    });
    try {
      final results = await widget.mapsService.searchPlaces(query);
      if (mounted) setState(() { _results = results; _isSearching = false; });
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Where to?',
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TutelaColors.plum)),
          const SizedBox(height: 4),
          Text('Search for your destination',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: TutelaColors.plum.withValues(alpha: 0.55))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.dmSans(color: TutelaColors.plum),
                decoration: InputDecoration(
                  hintText: 'e.g. Mall, Hospital, Jl. Raya…',
                  hintStyle: GoogleFonts.dmSans(
                      color: TutelaColors.plum.withValues(alpha: 0.42)),
                  filled: true,
                  fillColor: TutelaColors.ivory.withValues(alpha: 0.2),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: TutelaColors.plum.withValues(alpha: 0.14)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: TutelaColors.plum, width: 1.4),
                  ),
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _search,
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TutelaColors.plum,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.search_rounded,
                        color: Colors.white, size: 22),
              ),
            ),
          ]),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, _) =>
                    Divider(color: TutelaColors.plum.withValues(alpha: 0.08)),
                itemBuilder: (ctx, i) {
                  final r = _results[i];
                  final name = r['name'] as String?;
                  final address = r['formatted_address'] as String?;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.pop(
                      ctx,
                      GeoLocation(
                        latitude: r['latitude'] as double,
                        longitude: r['longitude'] as double,
                        address: address ?? name,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(children: [
                        const Icon(Icons.location_on_outlined,
                            color: TutelaColors.plum, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (name != null)
                                Text(name,
                                    style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              if (address != null)
                                Text(address,
                                    style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum
                                            .withValues(alpha: 0.55),
                                        fontSize: 11.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Shared UI components ──────────────────────────────────────────────────────

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          shape: BoxShape.circle,
          border:
              Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: TutelaColors.plum, size: 21),
      ),
    );
  }
}

class _DashboardActionButton extends StatelessWidget {
  const _DashboardActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = filled ? TutelaColors.plum : TutelaColors.canvas;
    final foreground = filled ? TutelaColors.canvas : TutelaColors.plum;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: TutelaColors.plum, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum
                  .withValues(alpha: filled ? 0.22 : 0.12),
              blurRadius: filled ? 13 : 9,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 19),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.dmSans(
                    color: foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0)),
          ],
        ),
      ),
    );
  }
}
