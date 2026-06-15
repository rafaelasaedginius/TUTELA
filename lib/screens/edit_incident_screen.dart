import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../models/geo_location_model.dart';
import '../models/incident_enums.dart';
import '../models/incident_model.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/incident_service.dart';
import '../services/maps_service.dart';
import '../theme/tutela_colors.dart';

class EditIncidentScreen extends StatefulWidget {
  const EditIncidentScreen({super.key, required this.incident});

  final Incident incident;

  @override
  State<EditIncidentScreen> createState() => _EditIncidentScreenState();
}

class _EditIncidentScreenState extends State<EditIncidentScreen> {
  final IncidentService _incidentService = IncidentService();
  final MapsService _mapsService = MapsService();

  MapController? _mapController;

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late IncidentCategory _category;
  late Severity _severity;
  late GeoLocation _location;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.incident;
    _titleController = TextEditingController(text: i.title);
    _descriptionController = TextEditingController(text: i.description);
    _category = i.category;
    _severity = i.severity;
    _location = i.location;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    try {
      final loc = await _mapsService.getCurrentLocation();
      setState(() => _location = loc);
      _mapController?.move(
        LatLng(loc.latitude, loc.longitude),
        15,
      );
    } catch (_) {
      _showMessage('Failed to get current location.');
    }
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _location = GeoLocation(
        latitude: point.latitude,
        longitude: point.longitude,
      );
    });
    try {
      final address = await _mapsService.reverseGeocode(
        point.latitude,
        point.longitude,
      );
      if (!mounted) return;
      setState(() {
        _location = GeoLocation(
          latitude: point.latitude,
          longitude: point.longitude,
          address: address,
        );
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      _showMessage('Title and description are required.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await _incidentService.updateIncident(widget.incident.id, {
        'title': title,
        'description': description,
        'category': _category.name,
        'severity': _severity.name,
        'location': _location.toMap(),
      });
      if (!mounted) return;
      _showMessage('Report updated.');
      Navigator.of(context).pop();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      _showMessage('Failed to update report.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
                Row(
                  children: [
                    _IconBtn(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit report',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Update your incident report.',
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _EditMap(
                          onMapCreated: (c) => _mapController = c,
                          location: _location,
                          onTap: _onMapTap,
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _useCurrentLocation,
                          child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: TutelaColors.canvas,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: TutelaColors.plum,
                                width: 1.3,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.my_location_rounded,
                                  color: TutelaColors.plum,
                                  size: 17,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Use current location',
                                  style: GoogleFonts.dmSans(
                                    color: TutelaColors.plum,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _AddressLine(location: _location),
                        const SizedBox(height: 16),
                        _Label('Title'),
                        const SizedBox(height: 9),
                        _TextBox(
                          controller: _titleController,
                          hint: 'Short title for this incident',
                        ),
                        const SizedBox(height: 14),
                        _Label('Incident type'),
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: IncidentCategory.values
                              .map(
                                (c) => _Pill(
                              label: c.label,
                              selected: _category == c,
                              onTap: () => setState(() => _category = c),
                            ),
                          )
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        _Label('Description'),
                        const SizedBox(height: 9),
                        _TextBox(
                          controller: _descriptionController,
                          hint: 'Add a short description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _Label('Severity level'),
                        const SizedBox(height: 9),
                        Row(
                          children: [
                            Expanded(
                              child: _Sev(
                                s: Severity.low,
                                selected: _severity == Severity.low,
                                onTap: () =>
                                    setState(() => _severity = Severity.low),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _Sev(
                                s: Severity.medium,
                                selected: _severity == Severity.medium,
                                onTap: () =>
                                    setState(() => _severity = Severity.medium),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _Sev(
                                s: Severity.high,
                                selected: _severity == Severity.high,
                                onTap: () =>
                                    setState(() => _severity = Severity.high),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _Sev(
                                s: Severity.critical,
                                selected: _severity == Severity.critical,
                                onTap: () => setState(
                                      () => _severity = Severity.critical,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: _isSaving ? null : _save,
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: TutelaColors.plum,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              _isSaving ? 'Saving...' : 'Save changes',
                              style: GoogleFonts.dmSans(
                                color: TutelaColors.canvas,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditMap extends StatefulWidget {
  const _EditMap({
    required this.onMapCreated,
    required this.location,
    required this.onTap,
  });

  final void Function(MapController) onMapCreated;
  final GeoLocation location;
  final ValueChanged<LatLng> onTap;

  @override
  State<_EditMap> createState() => _EditMapState();
}

class _EditMapState extends State<_EditMap> {
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMapCreated(_mapController);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pin = LatLng(widget.location.latitude, widget.location.longitude);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: pin,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: (_, point) => widget.onTap(point),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tutela.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: pin,
                  width: 36,
                  height: 36,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: TutelaColors.plum,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.location});
  final GeoLocation location;

  @override
  Widget build(BuildContext context) {
    final text = location.address ??
        '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
    return Row(
      children: [
        Icon(
          Icons.place_outlined,
          color: TutelaColors.plum.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: TutelaColors.plum,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _TextBox extends StatelessWidget {
  const _TextBox({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      cursorColor: TutelaColors.plum,
      style: GoogleFonts.dmSans(
        color: TutelaColors.plum,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          color: TutelaColors.plum.withValues(alpha: 0.42),
          fontSize: 14,
        ),
        filled: true,
        fillColor: TutelaColors.ivory.withValues(alpha: 0.2),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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

class _Pill extends StatelessWidget {
  const _Pill({
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
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
          ),
        ),
      ),
    );
  }
}

class _Sev extends StatelessWidget {
  const _Sev({
    required this.s,
    required this.selected,
    required this.onTap,
  });
  final Severity s;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? TutelaColors.peach.withValues(alpha: 0.36)
              : TutelaColors.canvas,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: selected
                ? TutelaColors.rose
                : TutelaColors.plum.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          s.label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.plum,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          shape: BoxShape.circle,
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: TutelaColors.plum, size: 21),
      ),
    );
  }
}