import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../models/attachment_model.dart';
import '../models/geo_location_model.dart';
import '../models/incident_enums.dart';
import '../models/incident_model.dart';
import '../services/cloudinary_service.dart';
import '../services/incident_service.dart';
import '../services/maps_service.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';
import 'edit_incident_screen.dart';
import 'incident_detail_screen.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  IncidentCategory _category = IncidentCategory.harassment;
  Severity _severity = Severity.medium;

  final IncidentService _incidentService = IncidentService();
  final MapsService _mapsService = MapsService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  MapController? _mapController;
  GeoLocation? _pickedLocation;
  final List<_LocalAttachment> _attachments = [];
  bool _isSubmitting = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Severity? _severityFilter;
  IncidentCategory? _categoryFilter;

  List<Map<String, dynamic>> _nearbyResults = [];
  bool _isSearchingNearby = false;
  String? _nearbyError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchNearbyIncidents() async {
    setState(() {
      _isSearchingNearby = true;
      _nearbyError = null;
    });
    try {
      final current = await _mapsService.getCurrentLocation();
      final results = await _mapsService.searchNearbyIncidents(
        currentLocation: current,
        radiusMeters: 5000,
      );
      setState(() => _nearbyResults = results);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      setState(() => _nearbyError = 'Failed to search nearby places.');
    } finally {
      if (mounted) setState(() => _isSearchingNearby = false);
    }
  }

  bool _matchesFilters(Incident incident) {
    if (_severityFilter != null && incident.severity != _severityFilter) {
      return false;
    }
    if (_categoryFilter != null && incident.category != _categoryFilter) {
      return false;
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      final inTitle = incident.title.toLowerCase().contains(q);
      final inDesc = incident.description.toLowerCase().contains(q);
      if (!inTitle && !inDesc) return false;
    }
    return true;
  }

  void _openCategoryFilter() async {
    final selected = await showModalBottomSheet<IncidentCategory?>(
      context: context,
      backgroundColor: TutelaColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by type',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SelectablePill(
                      label: 'All',
                      selected: _categoryFilter == null,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    for (final c in IncidentCategory.values)
                      _SelectablePill(
                        label: c.label,
                        selected: _categoryFilter == c,
                        onTap: () => Navigator.of(context).pop(c),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    setState(() => _categoryFilter = selected);
  }

  void _openSeverityFilter() async {
    final selected = await showModalBottomSheet<Severity?>(
      context: context,
      backgroundColor: TutelaColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by severity',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SelectablePill(
                      label: 'All',
                      selected: _severityFilter == null,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    for (final s in Severity.values)
                      _SelectablePill(
                        label: s.label,
                        selected: _severityFilter == s,
                        onTap: () => Navigator.of(context).pop(s),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    setState(() => _severityFilter = selected);
  }

  Future<void> _useCurrentLocation() async {
    try {
      final loc = await _mapsService.getCurrentLocation();
      setState(() => _pickedLocation = loc);
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
      _pickedLocation = GeoLocation(
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
        _pickedLocation = GeoLocation(
          latitude: point.latitude,
          longitude: point.longitude,
          address: address,
        );
      });
    } catch (_) {}
  }

  Future<void> _openAttachmentSheet() async {
    final source = await showModalBottomSheet<_AttachmentSource>(
      context: context,
      backgroundColor: TutelaColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: TutelaColors.plum.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Add attachment',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose where to get the file from.',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                _SheetTile(
                  icon: Icons.photo_camera_outlined,
                  label: 'Take photo',
                  subtitle: 'Open camera',
                  onTap: () =>
                      Navigator.of(context).pop(_AttachmentSource.camera),
                ),
                const SizedBox(height: 10),
                _SheetTile(
                  icon: Icons.photo_library_outlined,
                  label: 'Choose from gallery',
                  subtitle: 'Pick a photo or video',
                  onTap: () =>
                      Navigator.of(context).pop(_AttachmentSource.gallery),
                ),
                const SizedBox(height: 10),
                _SheetTile(
                  icon: Icons.attach_file_rounded,
                  label: 'Browse files',
                  subtitle: 'Document, audio, or any file',
                  onTap: () =>
                      Navigator.of(context).pop(_AttachmentSource.files),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;
    await _pickAttachment(source);
  }

  Future<void> _pickAttachment(_AttachmentSource source) async {
    try {
      switch (source) {
        case _AttachmentSource.camera:
          final image =
          await _imagePicker.pickImage(source: ImageSource.camera);
          if (image != null) {
            _addAttachment(File(image.path), _AttachmentKind.image);
          }
          break;
        case _AttachmentSource.gallery:
          final image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            _addAttachment(File(image.path), _AttachmentKind.image);
          }
          break;
        case _AttachmentSource.files:
          final result =
          await FilePicker.platform.pickFiles(allowMultiple: false);
          if (result != null && result.files.single.path != null) {
            _addAttachment(
              File(result.files.single.path!),
              _AttachmentKind.file,
            );
          }
          break;
      }
    } catch (_) {
      _showMessage('Failed to pick attachment.');
    }
  }

  void _addAttachment(File file, _AttachmentKind kind) {
    setState(() {
      _attachments.add(_LocalAttachment(file: file, kind: kind));
    });
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
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
                    _ReportIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: TutelaColors.rose.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: TutelaColors.rose,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Incident reports',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Share safety alerts with the community.',
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.58),
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
                const SizedBox(height: 14),
                TabBar(
                  controller: _tabController,
                  labelStyle: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                  unselectedLabelStyle: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                  labelColor: TutelaColors.plum,
                  unselectedLabelColor: TutelaColors.plum.withValues(alpha: 0.45),
                  indicatorColor: TutelaColors.plum,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: TutelaColors.plum.withValues(alpha: 0.1),
                  tabs: const [
                    Tab(text: 'File a report'),
                    Tab(text: 'Reports'),
                    Tab(text: 'My Reports'),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 14, bottom: 12),
                        child: _CrudPanel(
                          title: 'File a report',
                          subtitle: 'Pin a location and submit incident data.',
                          child: Column(
                            children: [
                              _PickerMap(
                                onMapCreated: (c) => _mapController = c,
                                picked: _pickedLocation,
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
                              _AddressLine(location: _pickedLocation),
                              const SizedBox(height: 14),
                              _SectionLabel('Title'),
                              const SizedBox(height: 9),
                              _ReportTextField(
                                controller: _titleController,
                                hint: 'Short title for this incident',
                              ),
                              const SizedBox(height: 14),
                              _SectionLabel('Incident type'),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: IncidentCategory.values
                                    .map(
                                      (c) => _SelectablePill(
                                    label: c.label,
                                    selected: _category == c,
                                    onTap: () {
                                      setState(() {
                                        _category = c;
                                      });
                                    },
                                  ),
                                )
                                    .toList(),
                              ),
                              const SizedBox(height: 14),
                              _SectionLabel('Attachments'),
                              const SizedBox(height: 9),
                              _AddAttachmentButton(onTap: _openAttachmentSheet),
                              if (_attachments.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Column(
                                  children: [
                                    for (var i = 0; i < _attachments.length; i++)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: i == _attachments.length - 1 ? 0 : 8,
                                        ),
                                        child: _AttachmentChip(
                                          attachment: _attachments[i],
                                          onRemove: () => _removeAttachment(i),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 14),
                              _SectionLabel('Description'),
                              const SizedBox(height: 9),
                              _ReportTextField(
                                controller: _descriptionController,
                                hint: 'Add a short description',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 14),
                              _SectionLabel('Severity level'),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SeverityButton(
                                      label: Severity.low.label,
                                      selected: _severity == Severity.low,
                                      onTap: () {
                                        setState(() {
                                          _severity = Severity.low;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SeverityButton(
                                      label: Severity.medium.label,
                                      selected: _severity == Severity.medium,
                                      onTap: () {
                                        setState(() {
                                          _severity = Severity.medium;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SeverityButton(
                                      label: Severity.high.label,
                                      selected: _severity == Severity.high,
                                      onTap: () {
                                        setState(() {
                                          _severity = Severity.high;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SeverityButton(
                                      label: Severity.critical.label,
                                      selected: _severity == Severity.critical,
                                      onTap: () {
                                        setState(() {
                                          _severity = Severity.critical;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _PrimaryActionButton(
                                label: _isSubmitting ? 'Saving...' : 'Save report',
                                onTap: _isSubmitting ? () {} : _submitReport,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 14, bottom: 12),
                        child: _CrudPanel(
                          title: 'Browse map pins',
                          subtitle: 'View community reports and filter the safety layer.',
                          child: Column(
                            children: [
                              _ReportTextField(
                                controller: _searchController,
                                hint: 'Search by title or description',
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _searchQuery = _searchController.text.trim();
                                        });
                                      },
                                      child: _FilterChipBox(
                                        icon: Icons.search_rounded,
                                        label: 'Search',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openCategoryFilter,
                                      child: _FilterChipBox(
                                        icon: Icons.tune_rounded,
                                        label: _categoryFilter?.label ?? 'Type',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _openSeverityFilter,
                                      child: _FilterChipBox(
                                        icon: Icons.speed_rounded,
                                        label: _severityFilter?.label ?? 'Severity',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _isSearchingNearby ? null : _searchNearbyIncidents,
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
                                        Icons.near_me_rounded,
                                        color: TutelaColors.plum,
                                        size: 17,
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        _isSearchingNearby
                                            ? 'Searching nearby...'
                                            : 'Search nearby (5 km)',
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
                              if (_nearbyError != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _nearbyError!,
                                  style: GoogleFonts.dmSans(
                                    color: TutelaColors.rose,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              Builder(builder: (ctx) {
                                if (_nearbyResults.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final displayed = _nearbyResults.where((r) {
                                  if (_categoryFilter != null &&
                                      r['category'] != _categoryFilter!.name) {
                                    return false;
                                  }
                                  if (_severityFilter != null &&
                                      r['severity'] != _severityFilter!.name) {
                                    return false;
                                  }
                                  return true;
                                }).toList();
                                if (displayed.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    for (var i = 0; i < displayed.length; i++)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: i == displayed.length - 1 ? 0 : 10,
                                        ),
                                        child: _ReportListItem(
                                          title: (displayed[i]['name'] ?? 'Unnamed Place') as String,
                                          meta: '${((displayed[i]['distance_meters'] as int) / 1000).toStringAsFixed(1)} km away'
                                              '${(displayed[i]['formatted_address'] as String?)?.isNotEmpty == true ? ' · ${displayed[i]['formatted_address']}' : ''}',
                                          status: 'Nearby',
                                          statusColor: TutelaColors.plum.withValues(alpha: 0.6),
                                        ),
                                      ),
                                  ],
                                );
                              }),
                              const SizedBox(height: 12),
                              StreamBuilder<List<Incident>>(
                                stream: _incidentService.streamIncidents(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      child: Text(
                                        'Loading reports...',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum.withValues(alpha: 0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  final currentUid = fb.FirebaseAuth.instance.currentUser?.uid;
                                  final incidents = (snapshot.data ?? [])
                                      .where(_matchesFilters)
                                      .where((i) => i.reporterId != currentUid)
                                      .toList();
                                  if (incidents.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      child: Text(
                                        'No reports yet.',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum.withValues(alpha: 0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: [
                                      for (var i = 0; i < incidents.length; i++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: i == incidents.length - 1 ? 0 : 10,
                                          ),
                                          child: _ReportListItem(
                                            title: incidents[i].title,
                                            meta: '${incidents[i].category.label} - ${incidents[i].severity.label}',
                                            status: incidents[i].status.label,
                                            statusColor: incidents[i].status.color,
                                            categoryIcon: incidents[i].category.icon,
                                            categoryColor: incidents[i].category.color,
                                            showActions: false,
                                            onTap: () => _openIncidentDetail(incidents[i]),
                                            onEdit: () => _openEdit(incidents[i]),
                                            onRemove: () => _confirmRemove(incidents[i].id),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 14, bottom: 12),
                        child: _CrudPanel(
                          title: 'My Reports',
                          subtitle: 'Incidents you have submitted.',
                          child: StreamBuilder<List<Incident>>(
                            stream: _incidentService.streamIncidents(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Text(
                                    'Loading reports...',
                                    style: GoogleFonts.dmSans(
                                      color: TutelaColors.plum.withValues(alpha: 0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }
                              final currentUid = fb.FirebaseAuth.instance.currentUser?.uid;
                              final myIncidents = (snapshot.data ?? [])
                                  .where((i) => i.reporterId == currentUid)
                                  .toList();
                              if (myIncidents.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Text(
                                    'You have not submitted any reports yet.',
                                    style: GoogleFonts.dmSans(
                                      color: TutelaColors.plum.withValues(alpha: 0.6),
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: [
                                  for (var i = 0; i < myIncidents.length; i++)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: i == myIncidents.length - 1 ? 0 : 10,
                                      ),
                                      child: _ReportListItem(
                                        title: myIncidents[i].title,
                                        meta: '${myIncidents[i].category.label} - ${myIncidents[i].severity.label}',
                                        status: myIncidents[i].status.label,
                                        statusColor: myIncidents[i].status.color,
                                        categoryIcon: myIncidents[i].category.icon,
                                        categoryColor: myIncidents[i].category.color,
                                        showActions: true,
                                        onTap: () => _openIncidentDetail(myIncidents[i]),
                                        onEdit: () => _openEdit(myIncidents[i]),
                                        onRemove: () => _confirmRemove(myIncidents[i].id),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
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

  Future<void> _submitReport() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showMessage('Please fill in the title and description.');
      return;
    }
    if (_pickedLocation == null) {
      _showMessage('Please pick a location on the map.');
      return;
    }

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('You must be signed in to submit a report.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final uploaded = <Attachment>[];
      for (final a in _attachments) {
        final result = await _cloudinaryService.uploadFile(
          a.file,
          folder: 'incidents',
        );
        uploaded.add(result);
      }

      final now = Timestamp.now();
      final incident = Incident(
        id: '',
        reporterId: user.uid,
        title: title,
        description: description,
        category: _category,
        severity: _severity,
        location: _pickedLocation!,
        geohash: '',
        attachments: uploaded,
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      );
      await _incidentService.createIncident(incident);

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _category = IncidentCategory.harassment;
        _severity = Severity.medium;
        _pickedLocation = null;
        _attachments.clear();
      });
      _showMessage('Report saved.');
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      _showMessage('Failed to save report.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmRemove(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Remove report?',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'This will permanently delete the report.',
            style: GoogleFonts.dmSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await _incidentService.deleteIncident(id);
        _showMessage('Report removed.');
      } catch (e, s) {
        FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
        _showMessage('Failed to remove report.');
      }
    }
  }

  void _openEdit(Incident incident) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => EditIncidentScreen(incident: incident),
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openIncidentDetail(Incident incident) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => IncidentDetailScreen(incident: incident),
      ),
    );
  }
}

enum _AttachmentSource { camera, gallery, files }

enum _AttachmentKind { image, file }

class _LocalAttachment {
  _LocalAttachment({required this.file, required this.kind});
  final File file;
  final _AttachmentKind kind;

  String get name => file.path.split(Platform.pathSeparator).last;
}

class _AddAttachmentButton extends StatelessWidget {
  const _AddAttachmentButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: TutelaColors.ivory.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: TutelaColors.plum.withValues(alpha: 0.18),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: TutelaColors.peach.withValues(alpha: 0.34),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: TutelaColors.plum,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add attachment',
                    style: GoogleFonts.dmSans(
                      color: TutelaColors.plum,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Camera, gallery, or file manager',
                    style: GoogleFonts.dmSans(
                      color: TutelaColors.plum.withValues(alpha: 0.58),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: TutelaColors.plum.withValues(alpha: 0.55),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({required this.attachment, required this.onRemove});
  final _LocalAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.kind == _AttachmentKind.image;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isImage
                ? Image.file(
              attachment.file,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _FilePlaceholder(),
            )
                : _FilePlaceholder(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isImage ? 'Image' : 'File',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum.withValues(alpha: 0.55),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onRemove,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: TutelaColors.rose.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: TutelaColors.rose,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      color: TutelaColors.peach.withValues(alpha: 0.34),
      alignment: Alignment.center,
      child: const Icon(
        Icons.insert_drive_file_outlined,
        color: TutelaColors.plum,
        size: 19,
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: TutelaColors.ivory.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: TutelaColors.peach.withValues(alpha: 0.36),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: TutelaColors.plum, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.dmSans(
                      color: TutelaColors.plum,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      color: TutelaColors.plum.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.1,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: TutelaColors.plum.withValues(alpha: 0.55),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerMap extends StatefulWidget {
  const _PickerMap({
    required this.onMapCreated,
    required this.picked,
    required this.onTap,
  });

  static const LatLng _defaultCenter = LatLng(-6.1751, 106.8272);

  final void Function(MapController) onMapCreated;
  final GeoLocation? picked;
  final ValueChanged<LatLng> onTap;

  @override
  State<_PickerMap> createState() => _PickerMapState();
}

class _PickerMapState extends State<_PickerMap> {
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
    final center = widget.picked == null
        ? _PickerMap._defaultCenter
        : LatLng(widget.picked!.latitude, widget.picked!.longitude);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
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
                if (widget.picked != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(widget.picked!.latitude, widget.picked!.longitude),
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
            if (widget.picked == null)
              IgnorePointer(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: TutelaColors.canvas.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tap map to pin location',
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
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

class _AddressLine extends StatelessWidget {
  const _AddressLine({required this.location});
  final GeoLocation? location;

  @override
  Widget build(BuildContext context) {
    final text = location == null
        ? 'No location pinned yet.'
        : (location!.address ??
        '${location!.latitude.toStringAsFixed(5)}, ${location!.longitude.toStringAsFixed(5)}');
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

class _CrudPanel extends StatelessWidget {
  const _CrudPanel({
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
          Column(
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
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
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
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SeverityButton extends StatelessWidget {
  const _SeverityButton({
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

class _FilterChipBox extends StatelessWidget {
  const _FilterChipBox({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: TutelaColors.plum, size: 17),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportListItem extends StatelessWidget {
  const _ReportListItem({
    required this.title,
    required this.meta,
    required this.status,
    this.statusColor,
    this.categoryIcon,
    this.categoryColor,
    this.showActions = false,
    this.onTap,
    this.onEdit,
    this.onRemove,
  });

  final String title;
  final String meta;
  final String status;
  final Color? statusColor;
  final IconData? categoryIcon;
  final Color? categoryColor;
  final bool showActions;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: TutelaColors.ivory.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (categoryColor ?? TutelaColors.rose).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoryIcon ?? Icons.location_on_outlined,
                    color: categoryColor ?? TutelaColors.plum,
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
                  status,
                  style: GoogleFonts.dmSans(
                    color: statusColor ?? TutelaColors.rose,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: TutelaColors.plum,
                    size: 20,
                  ),
                ],
              ],
            ),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SecondaryActionButton(
                      icon: Icons.edit_note_rounded,
                      label: 'Edit report',
                      onTap: onEdit ?? () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DangerActionButton(
                      label: 'Remove',
                      onTap: onRemove ?? () {},
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportTextField extends StatelessWidget {
  const _ReportTextField({
    required this.hint,
    this.controller,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

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

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
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

class _DangerActionButton extends StatelessWidget {
  const _DangerActionButton({required this.label, required this.onTap});

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

class _ReportIconButton extends StatelessWidget {
  const _ReportIconButton({required this.icon, required this.onTap});

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
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
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