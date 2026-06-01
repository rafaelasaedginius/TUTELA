import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cloudinaryImage_model.dart';
import '../models/geo_location_model.dart';
import '../models/incident_enums.dart';
import '../models/incident_model.dart';
import '../services/incident_service.dart';
import '../services/maps_service.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';
import 'incident_detail_screen.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  IncidentCategory _category = IncidentCategory.harassment;
  Severity _severity = Severity.medium;

  final IncidentService _incidentService = IncidentService();
  final MapsService _mapsService = MapsService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
                // Incident Reports Header Start
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
                            'CRUD safety data layer',
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
                // Incident Reports Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Create Report Section Start
                        _CrudPanel(
                          title: 'File a report',
                          subtitle: 'Pin a location and submit incident data.',
                          child: Column(
                            children: [
                              _MapPinBox(),
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
                              _SectionLabel('Attach photos'),
                              const SizedBox(height: 9),
                              const Row(
                                children: [
                                  _PhotoSlot(label: '1'),
                                  SizedBox(width: 10),
                                  _PhotoSlot(label: '2'),
                                  SizedBox(width: 10),
                                  _PhotoSlot(label: '3'),
                                ],
                              ),
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
                                label: _isSubmitting
                                    ? 'Saving...'
                                    : 'Save report',
                                onTap: _isSubmitting ? () {} : _submitReport,
                              ),
                            ],
                          ),
                        ),
                        // Create Report Section End
                        const SizedBox(height: 14),
                        // Read Reports Section Start
                        _CrudPanel(
                          title: 'Browse map pins',
                          subtitle:
                          'View community reports and filter the safety layer.',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _FilterChipBox(
                                      icon: Icons.tune_rounded,
                                      label: 'Type',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _FilterChipBox(
                                      icon: Icons.speed_rounded,
                                      label: 'Severity',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _FilterChipBox(
                                      icon: Icons.social_distance_rounded,
                                      label: '1-5 km',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              StreamBuilder<List<Incident>>(
                                stream: _incidentService.streamIncidents(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      child: Text(
                                        'Loading reports...',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  final incidents = snapshot.data ?? [];
                                  if (incidents.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      child: Text(
                                        'No reports yet.',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum.withValues(
                                            alpha: 0.6,
                                          ),
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  final currentUid =
                                      fb.FirebaseAuth.instance.currentUser?.uid;
                                  return Column(
                                    children: [
                                      for (var i = 0; i < incidents.length; i++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: i == incidents.length - 1
                                                ? 0
                                                : 10,
                                          ),
                                          child: _ReportListItem(
                                            title: incidents[i].title,
                                            meta:
                                            '${incidents[i].category.label} - ${incidents[i].severity.label}',
                                            status: incidents[i].status.name,
                                            showActions:
                                            incidents[i].reporterId ==
                                                currentUid,
                                            onTap: () => _openIncidentDetail(
                                              incidents[i],
                                            ),
                                            onRemove: () => _confirmRemove(
                                              incidents[i].id,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        // Read Reports Section End
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Bottom Navigation Start
                const TutelaBottomNav(selected: TutelaNavTab.map),
                // Bottom Navigation End
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

    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('You must be signed in to submit a report.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      GeoLocation location;
      try {
        location = await _mapsService.getCurrentLocation();
      } catch (_) {
        location = const GeoLocation(
          latitude: 0,
          longitude: 0,
          label: 'Location unavailable',
        );
      }

      final now = Timestamp.now();
      final incident = Incident(
        id: '',
        reporterId: user.uid,
        title: title,
        description: description,
        category: _category,
        severity: _severity,
        location: location,
        geohash: '',
        photos: const <CloudinaryImage>[],
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
      });
      _showMessage('Report saved.');
    } catch (e) {
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
            'This will soft-delete the report. You can no longer see it on the map.',
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
        await _incidentService.softDeleteIncident(id);
        _showMessage('Report removed.');
      } catch (e) {
        _showMessage('Failed to remove report.');
      }
    }
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
        builder: (context) => IncidentDetailScreen(
          title: incident.title,
          location: incident.location.address ??
              incident.location.label ??
              '-',
          severity: incident.severity.label,
          status: incident.status.name,
        ),
      ),
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
          // CRUD Panel Header Start
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
          // CRUD Panel Header End
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MapPinBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MiniMapPainter())),
          Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: TutelaColors.rose,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TutelaColors.rose.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: TutelaColors.canvas,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = TutelaColors.plum.withValues(alpha: 0.1)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final route = Paint()
      ..color = TutelaColors.rose.withValues(alpha: 0.34)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.3),
      Offset(size.width * 0.92, size.height * 0.16),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.22, size.height),
      Offset(size.width * 0.74, 0),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.78),
      Offset(size.width * 0.88, size.height * 0.45),
      route,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: TutelaColors.ivory.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: TutelaColors.plum,
              size: 19,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
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
    this.showActions = false,
    this.onTap,
    this.onRemove,
  });

  final String title;
  final String meta;
  final String status;
  final bool showActions;
  final VoidCallback? onTap;
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
                    color: TutelaColors.rose.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: TutelaColors.plum,
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
                    color: TutelaColors.rose,
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
                      label: 'Follow-up',
                      onTap: () {},
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