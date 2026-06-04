import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../models/geo_location_model.dart';
import '../models/safe_route_model.dart';
import '../services/maps_service.dart';
import '../services/safe_route_service.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';

class SafeRoutePlannerScreen extends StatefulWidget {
  const SafeRoutePlannerScreen({super.key});

  @override
  State<SafeRoutePlannerScreen> createState() => _SafeRoutePlannerScreenState();
}

class _SafeRoutePlannerScreenState extends State<SafeRoutePlannerScreen> {
  final _safeRouteService = SafeRouteService();
  final _mapsService = MapsService();
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  GeoLocation? _origin;
  GeoLocation? _destination;
  List<GeoLocation>? _routePoints;
  List<String> _selectedTags = [];
  bool _isShared = false;
  bool _isSaving = false;
  bool _isLoadingRoute = false;

  List<SafeRoute> _myRoutes = [];
  List<SafeRoute> _sharedRoutes = [];
  StreamSubscription<List<SafeRoute>>? _mySub;
  StreamSubscription<List<SafeRoute>>? _sharedSub;

  String _selectedSort = 'Recency';

  @override
  void initState() {
    super.initState();
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _mySub = _safeRouteService.streamMyRoutes(uid).listen(
        (routes) { if (mounted) setState(() => _myRoutes = routes); },
        onError: (_) {},
      );
      _sharedSub = _safeRouteService.streamSharedRoutes().listen(
        (routes) { if (mounted) setState(() => _sharedRoutes = routes); },
        onError: (_) {},
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _mySub?.cancel();
    _sharedSub?.cancel();
    super.dispose();
  }

  // ── Computed ──────────────────────────────────────────────────────────────

  List<SafeRoute> get _sortedRoutes {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    final othersShared = _sharedRoutes.where((r) => r.creatorId != uid).toList();
    final all = [..._myRoutes, ...othersShared];
    if (_selectedSort == 'Recency') {
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return all;
  }

  String get _originLabel {
    if (_origin == null) return 'Tap to set origin';
    return _origin!.address ??
        '${_origin!.latitude.toStringAsFixed(4)}, ${_origin!.longitude.toStringAsFixed(4)}';
  }

  String get _destinationLabel {
    if (_destination == null) return 'Tap to set destination';
    return _destination!.address ??
        '${_destination!.latitude.toStringAsFixed(4)}, ${_destination!.longitude.toStringAsFixed(4)}';
  }

  String _routeMeta(SafeRoute route) {
    final dest = route.destination.address?.split(',').first.trim() ??
        '${route.destination.latitude.toStringAsFixed(3)}, ${route.destination.longitude.toStringAsFixed(3)}';
    return 'To: $dest';
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _fetchRoute() async {
    if (_origin == null || _destination == null || _isLoadingRoute) return;
    setState(() { _isLoadingRoute = true; _routePoints = null; });
    try {
      final points = await _mapsService.getRoute(
        origin: _origin!,
        destination: _destination!,
      );
      if (mounted) setState(() => _routePoints = points);
    } catch (_) {
      // Non-critical — markers still show without a polyline
    } finally {
      if (mounted) setState(() => _isLoadingRoute = false);
    }
  }

  Future<void> _showLocationSearchDialog(bool isOrigin) async {
    final loc = await showModalBottomSheet<GeoLocation>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => _LocationSearchSheet(
        mapsService: _mapsService,
        title: isOrigin ? 'Set origin' : 'Set destination',
      ),
    );
    if (loc == null || !mounted) return;
    setState(() {
      if (isOrigin) {
        _origin = loc;
      } else {
        _destination = loc;
      }
    });
    _fetchRoute();
  }

  Future<void> _handleMapTap(LatLng point) async {
    if (!mounted) return;
    final result = await Navigator.of(context).push<_MapPickResult>(
      MaterialPageRoute(
        builder: (_) => _MapPickerPage(
          mapsService: _mapsService,
          initialCenter: point,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.isOrigin) {
        _origin = result.location;
      } else {
        _destination = result.location;
      }
    });
    _fetchRoute();
  }

  void _viewRouteOnMap(SafeRoute route) {
    setState(() {
      _origin = route.origin;
      _destination = route.destination;
      _routePoints = null;
    });
    _fetchRoute();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> _saveRoute() async {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_origin == null) {
      _showMessage('Please set your starting point.');
      return;
    }
    if (_destination == null) {
      _showMessage('Please set your destination.');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Please name this route.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final now = Timestamp.now();
      await _safeRouteService.createRoute(SafeRoute(
        id: '',
        creatorId: uid,
        name: _nameController.text.trim(),
        origin: _origin!,
        destination: _destination!,
        safetyTags: List.from(_selectedTags),
        isShared: _isShared,
        isFlagged: false,
        createdAt: now,
        updatedAt: now,
      ));
      setState(() {
        _origin = null;
        _destination = null;
        _routePoints = null;
        _selectedTags = [];
        _isShared = false;
      });
      _nameController.clear();
      if (mounted) _showMessage('Route saved!');
    } catch (_) {
      if (mounted) _showMessage('Failed to save route.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _editTags(SafeRoute route) async {
    List<String> tags = List.from(route.safetyTags);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit safety tags',
                  style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: TutelaColors.plum)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in [
                    'Well-lit',
                    'Busy street',
                    'CCTV present',
                  ])
                    _SelectableTag(
                      label: tag,
                      selected: tags.contains(tag),
                      onTap: () => setBS(() {
                        tags.contains(tag)
                            ? tags.remove(tag)
                            : tags.add(tag);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _PrimaryRouteButton(
                  label: 'Save tags',
                  onTap: () => Navigator.pop(ctx, true)),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      await _safeRouteService.updateRoute(route.id, {'safetyTags': tags});
    }
  }

  Future<void> _toggleFlag(SafeRoute route) async {
    await _safeRouteService
        .updateRoute(route.id, {'isFlagged': !route.isFlagged});
  }

  Future<void> _deleteRoute(SafeRoute route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete route?',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700, color: TutelaColors.plum)),
        content: Text('This will permanently delete "${route.name}".',
            style: GoogleFonts.dmSans(color: TutelaColors.plum)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: TutelaColors.plum)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.dmSans(
                    color: TutelaColors.rose,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _safeRouteService.deleteRoute(route.id);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      _selectedTags.contains(tag)
          ? _selectedTags.remove(tag)
          : _selectedTags.add(tag);
    });
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg, style: GoogleFonts.dmSans())));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    final size = MediaQuery.sizeOf(context);
    final contentWidth = (size.width - 32).clamp(300.0, 430.0);
    final routes = _sortedRoutes;

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Safe Route Header Start
                Row(
                  children: [
                    _RouteIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context)
                          .pushReplacementNamed(TutelaRoutes.home),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F2FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.route_rounded,
                        color: Color(0xFF337AA8),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Safe routes',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Mobility layer',
                            style: GoogleFonts.dmSans(
                              color:
                                  TutelaColors.plum.withValues(alpha: 0.58),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Safe Route Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        // Save Route Section Start
                        _RoutePanel(
                          title: 'Save a route',
                          subtitle:
                              'Draw or auto-generate a path between two points.',
                          child: Column(
                            children: [
                              _LiveMapBox(
                                origin: _origin,
                                destination: _destination,
                                routePoints: _routePoints,
                                isLoadingRoute: _isLoadingRoute,
                                onMapTap: _handleMapTap,
                              ),
                              const SizedBox(height: 14),
                              // From / To row — both tappable
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showLocationSearchDialog(true),
                                      child: _RouteFieldBox(
                                        label: 'From',
                                        value: _originLabel,
                                        icon: Icons.my_location_rounded,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showLocationSearchDialog(false),
                                      child: _RouteFieldBox(
                                        label: 'To',
                                        value: _destinationLabel,
                                        icon: Icons.flag_rounded,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SectionLabel('Safety notes'),
                              const SizedBox(height: 9),
                              // Tags are now multi-select
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _SelectableTag(
                                    label: 'Well-lit',
                                    selected:
                                        _selectedTags.contains('Well-lit'),
                                    onTap: () => _toggleTag('Well-lit'),
                                  ),
                                  _SelectableTag(
                                    label: 'Busy street',
                                    selected: _selectedTags
                                        .contains('Busy street'),
                                    onTap: () => _toggleTag('Busy street'),
                                  ),
                                  _SelectableTag(
                                    label: 'CCTV present',
                                    selected: _selectedTags
                                        .contains('CCTV present'),
                                    onTap: () => _toggleTag('CCTV present'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _RouteTextField(
                                hint: 'Name this route',
                                controller: _nameController,
                              ),
                              const SizedBox(height: 12),
                              // Share toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Share with community',
                                    style: GoogleFonts.dmSans(
                                      color: TutelaColors.plum,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: _isShared,
                                    onChanged: (v) =>
                                        setState(() => _isShared = v),
                                    activeThumbColor: TutelaColors.plum,
                                    activeTrackColor: TutelaColors.plum.withValues(alpha: 0.55),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              _PrimaryRouteButton(
                                label: _isSaving ? 'Saving…' : 'Save route',
                                onTap: _isSaving ? () {} : _saveRoute,
                              ),
                            ],
                          ),
                        ),
                        // Save Route Section End
                        const SizedBox(height: 14),
                        // View Saved Routes Section Start
                        _RoutePanel(
                          title: 'View saved routes',
                          subtitle:
                              'Browse personal and community-shared safe routes.',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _SortChip(
                                      label: 'Rating',
                                      selected: _selectedSort == 'Rating',
                                      onTap: () => setState(
                                          () => _selectedSort = 'Rating'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SortChip(
                                      label: 'Recency',
                                      selected: _selectedSort == 'Recency',
                                      onTap: () => setState(
                                          () => _selectedSort = 'Recency'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SortChip(
                                      label: 'Distance',
                                      selected: _selectedSort == 'Distance',
                                      onTap: () => setState(
                                          () => _selectedSort = 'Distance'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (routes.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'No routes saved yet.',
                                    style: GoogleFonts.dmSans(
                                      color: TutelaColors.plum
                                          .withValues(alpha: 0.45),
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              else
                                for (int i = 0; i < routes.length; i++) ...[
                                  _SavedRouteItem(
                                    title: routes[i].name,
                                    meta: _routeMeta(routes[i]),
                                    tag: routes[i].isShared
                                        ? 'Shared'
                                        : 'Personal',
                                    isFlagged: routes[i].isFlagged,
                                    showActions:
                                        routes[i].creatorId == uid,
                                    onViewOnMap: () =>
                                        _viewRouteOnMap(routes[i]),
                                    onEditTags: () => _editTags(routes[i]),
                                    onFlag: () => _toggleFlag(routes[i]),
                                    onDelete: () => _deleteRoute(routes[i]),
                                  ),
                                  if (i < routes.length - 1)
                                    const SizedBox(height: 10),
                                ],
                            ],
                          ),
                        ),
                        // View Saved Routes Section End
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Bottom Navigation Start
                const TutelaBottomNav(selected: TutelaNavTab.route),
                // Bottom Navigation End
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets (unchanged from original, with targeted additions) ────────────────

class _RoutePanel extends StatelessWidget {
  const _RoutePanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TutelaColors.canvas,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.62),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LiveMapBox extends StatefulWidget {
  const _LiveMapBox({
    this.origin,
    this.destination,
    this.routePoints,
    this.isLoadingRoute = false,
    this.onMapTap,
  });

  final GeoLocation? origin;
  final GeoLocation? destination;
  final List<GeoLocation>? routePoints;
  final bool isLoadingRoute;
  final void Function(LatLng)? onMapTap;

  @override
  State<_LiveMapBox> createState() => _LiveMapBoxState();
}

class _LiveMapBoxState extends State<_LiveMapBox> {
  final _controller = MapController();

  static const _defaultCenter = LatLng(-2.5, 117.5);
  static const _defaultZoom = 4.0;

  @override
  void didUpdateWidget(_LiveMapBox old) {
    super.didUpdateWidget(old);
    if (widget.origin != old.origin ||
        widget.destination != old.destination ||
        widget.routePoints != old.routePoints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fitCamera();
      });
    }
  }

  void _fitCamera() {
    final coords = _keyCoords;
    if (coords.isEmpty) {
      _controller.move(_defaultCenter, _defaultZoom);
      return;
    }
    if (coords.length == 1) {
      _controller.move(coords.first, 14);
      return;
    }
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: coords,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  List<LatLng> get _keyCoords {
    return [
      if (widget.origin != null)
        LatLng(widget.origin!.latitude, widget.origin!.longitude),
      if (widget.destination != null)
        LatLng(widget.destination!.latitude, widget.destination!.longitude),
    ];
  }

  List<LatLng> get _polylineCoords {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) return [];
    return widget.routePoints!
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: _defaultZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
                onTap: (_, point) => widget.onMapTap?.call(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tutela.app',
                ),
                if (_polylineCoords.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _polylineCoords,
                        color: const Color(0xFF337AA8),
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (widget.origin != null)
                      Marker(
                        point: LatLng(widget.origin!.latitude,
                            widget.origin!.longitude),
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.my_location_rounded,
                            color: TutelaColors.plum, size: 30),
                      ),
                    if (widget.destination != null)
                      Marker(
                        point: LatLng(widget.destination!.latitude,
                            widget.destination!.longitude),
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.flag_rounded,
                            color: TutelaColors.rose, size: 30),
                      ),
                  ],
                ),
              ],
            ),
            if (widget.isLoadingRoute)
              Positioned.fill(
                child: ColoredBox(
                  color: TutelaColors.canvas.withValues(alpha: 0.55),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF337AA8),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ),
            // Hint badge
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tap to pick point on map',
                      style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteFieldBox extends StatelessWidget {
  const _RouteFieldBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TutelaColors.plum, size: 18),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.55),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectableTag extends StatelessWidget {
  const _SelectableTag({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? TutelaColors.plum : TutelaColors.canvas,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: TutelaColors.plum, width: 1.2),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: selected ? TutelaColors.canvas : TutelaColors.plum,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE4F2FF)
              : TutelaColors.ivory.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF337AA8)
                : TutelaColors.plum.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.plum,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SavedRouteItem extends StatelessWidget {
  const _SavedRouteItem({
    required this.title,
    required this.meta,
    required this.tag,
    this.showActions = false,
    this.isFlagged = false,
    this.onViewOnMap,
    this.onEditTags,
    this.onFlag,
    this.onDelete,
  });

  final String title;
  final String meta;
  final String tag;
  final bool showActions;
  final bool isFlagged;
  final VoidCallback? onViewOnMap;
  final VoidCallback? onEditTags;
  final VoidCallback? onFlag;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isFlagged
                ? TutelaColors.rose.withValues(alpha: 0.35)
                : TutelaColors.plum.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4F2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Color(0xFF337AA8),
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      meta,
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                tag,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF337AA8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SecondaryRouteButton(
            icon: Icons.map_outlined,
            label: 'View on map',
            onTap: onViewOnMap ?? () {},
          ),
          if (showActions) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SecondaryRouteButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit tags',
                    onTap: onEditTags ?? () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SecondaryRouteButton(
                    icon: isFlagged ? Icons.flag : Icons.flag_outlined,
                    label: isFlagged ? 'Flagged' : 'Flag',
                    onTap: onFlag ?? () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DangerRouteButton(
                      label: 'Delete', onTap: onDelete ?? () {}),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteTextField extends StatelessWidget {
  const _RouteTextField({required this.hint, this.controller});

  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 1,
      cursorColor: TutelaColors.plum,
      style: GoogleFonts.dmSans(
        color: TutelaColors.plum,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          color: TutelaColors.plum.withValues(alpha: 0.42),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        filled: true,
        fillColor: TutelaColors.ivory.withValues(alpha: 0.2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: TutelaColors.plum.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: TutelaColors.plum, width: 1.4),
        ),
      ),
    );
  }
}

class _PrimaryRouteButton extends StatelessWidget {
  const _PrimaryRouteButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.plum,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.canvas,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SecondaryRouteButton extends StatelessWidget {
  const _SecondaryRouteButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: TutelaColors.plum, width: 1.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: TutelaColors.plum, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerRouteButton extends StatelessWidget {
  const _DangerRouteButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.rose.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: TutelaColors.rose, width: 1.3),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.rose,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: TutelaColors.plum,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _RouteIconButton extends StatelessWidget {
  const _RouteIconButton({required this.icon, required this.onTap});

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
              color: TutelaColors.plum.withValues(alpha: 0.08),
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

class _LocationSearchSheet extends StatefulWidget {
  const _LocationSearchSheet({
    required this.mapsService,
    required this.title,
  });

  final MapsService mapsService;
  final String title;

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _isLocating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() { _isSearching = true; _results = []; });
    try {
      final results = await widget.mapsService.searchPlaces(query);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final loc = await widget.mapsService.getCurrentLocation();
      if (mounted) Navigator.pop(context, loc);
    } catch (_) {
      if (mounted) {
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not get location.',
                style: GoogleFonts.dmSans())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TutelaColors.plum),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _isLocating ? null : _useCurrentLocation,
              child: Container(
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TutelaColors.plum.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: TutelaColors.plum.withValues(alpha: 0.18)),
                ),
                child: _isLocating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: TutelaColors.plum))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.my_location_rounded,
                              color: TutelaColors.plum, size: 18),
                          const SizedBox(width: 8),
                          Text('Use current location',
                              style: GoogleFonts.dmSans(
                                  color: TutelaColors.plum,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.dmSans(color: TutelaColors.plum),
                    decoration: InputDecoration(
                      hintText: 'Search for a place…',
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
                        borderSide: const BorderSide(
                            color: TutelaColors.plum, width: 1.4),
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
              ],
            ),
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => Divider(
                      color: TutelaColors.plum.withValues(alpha: 0.08)),
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
                        child: Row(
                          children: [
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Full-screen map picker ────────────────────────────────────────────────────

class _MapPickResult {
  const _MapPickResult({required this.isOrigin, required this.location});
  final bool isOrigin;
  final GeoLocation location;
}

class _MapPickerPage extends StatefulWidget {
  const _MapPickerPage({required this.mapsService, this.initialCenter});
  final MapsService mapsService;
  final LatLng? initialCenter;

  @override
  State<_MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<_MapPickerPage> {
  final _controller = MapController();
  Timer? _debounce;
  late LatLng _center;
  String? _address;
  bool _isGeocoding = false;

  static const _defaultCenter = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _center = widget.initialCenter ?? _defaultCenter;
    _reverseGeocode(_center);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _center = camera.center;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      _reverseGeocode(_center);
    });
  }

  Future<void> _reverseGeocode(LatLng point) async {
    if (!mounted) return;
    setState(() => _isGeocoding = true);
    try {
      final address = await widget.mapsService
          .reverseGeocode(point.latitude, point.longitude);
      if (mounted) {
        setState(() {
          _address = address;
          _isGeocoding = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  void _confirm(bool isOrigin) {
    Navigator.of(context).pop(_MapPickResult(
      isOrigin: isOrigin,
      location: GeoLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen interactive map
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onPositionChanged: _onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tutela.app',
              ),
            ],
          ),

          // Crosshair pin: tip aligned to map centre
          Align(
            alignment: Alignment.center,
            child: Transform.translate(
              offset: const Offset(0, -22),
              child: const Icon(Icons.location_pin,
                  color: TutelaColors.plum, size: 44),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: TutelaColors.plum, size: 22),
                ),
              ),
            ),
          ),

          // Bottom panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                decoration: BoxDecoration(
                  color: TutelaColors.canvas,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: TutelaColors.plum.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected location',
                      style: GoogleFonts.dmSans(
                          color: TutelaColors.plum.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 6),
                    if (_isGeocoding)
                      Row(children: [
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: TutelaColors.plum),
                        ),
                        const SizedBox(width: 8),
                        Text('Finding address…',
                            style: GoogleFonts.dmSans(
                                color:
                                    TutelaColors.plum.withValues(alpha: 0.55),
                                fontSize: 13)),
                      ])
                    else
                      Text(
                        _address ??
                            '${_center.latitude.toStringAsFixed(5)}, '
                                '${_center.longitude.toStringAsFixed(5)}',
                        style: GoogleFonts.dmSans(
                            color: TutelaColors.plum,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryRouteButton(
                            label: 'Set as origin',
                            onTap: () => _confirm(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SecondaryRouteButton(
                            icon: Icons.flag_rounded,
                            label: 'Set as destination',
                            onTap: () => _confirm(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
