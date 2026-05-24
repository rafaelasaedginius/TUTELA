import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  String _incidentType = 'Harassment';
  String _severity = 'Medium';
  String _status = 'Ongoing';

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
                              _SectionLabel('Incident type'),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _SelectablePill(
                                    label: 'Harassment',
                                    selected: _incidentType == 'Harassment',
                                    onTap: () {
                                      setState(() {
                                        _incidentType = 'Harassment';
                                      });
                                    },
                                  ),
                                  _SelectablePill(
                                    label: 'Poor lighting',
                                    selected: _incidentType == 'Poor lighting',
                                    onTap: () {
                                      setState(() {
                                        _incidentType = 'Poor lighting';
                                      });
                                    },
                                  ),
                                  _SelectablePill(
                                    label: 'Assault',
                                    selected: _incidentType == 'Assault',
                                    onTap: () {
                                      setState(() {
                                        _incidentType = 'Assault';
                                      });
                                    },
                                  ),
                                ],
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
                              _ReportTextField(
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
                                      label: 'Low',
                                      selected: _severity == 'Low',
                                      onTap: () {
                                        setState(() {
                                          _severity = 'Low';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SeverityButton(
                                      label: 'Medium',
                                      selected: _severity == 'Medium',
                                      onTap: () {
                                        setState(() {
                                          _severity = 'Medium';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SeverityButton(
                                      label: 'High',
                                      selected: _severity == 'High',
                                      onTap: () {
                                        setState(() {
                                          _severity = 'High';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _PrimaryActionButton(
                                label: 'Save report',
                                onTap: () {},
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
                              const _ReportListItem(
                                title: 'Poor lighting',
                                meta: '0.8 km away - Medium',
                                status: 'Ongoing',
                              ),
                              const SizedBox(height: 10),
                              const _ReportListItem(
                                title: 'Harassment report',
                                meta: '1.4 km away - High',
                                status: 'Escalated',
                              ),
                            ],
                          ),
                        ),
                        // Read Reports Section End
                        const SizedBox(height: 14),
                        // Update Report Section Start
                        _CrudPanel(
                          title: 'Add follow-up',
                          subtitle:
                              'Change report status and append notes or photos.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionLabel('Status'),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Expanded(
                                    child: _StatusButton(
                                      label: 'Ongoing',
                                      selected: _status == 'Ongoing',
                                      onTap: () {
                                        setState(() {
                                          _status = 'Ongoing';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatusButton(
                                      label: 'Resolved',
                                      selected: _status == 'Resolved',
                                      onTap: () {
                                        setState(() {
                                          _status = 'Resolved';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _StatusButton(
                                      label: 'Escalated',
                                      selected: _status == 'Escalated',
                                      onTap: () {
                                        setState(() {
                                          _status = 'Escalated';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _ReportTextField(
                                hint: 'Add follow-up notes',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              _SecondaryActionButton(
                                icon: Icons.add_photo_alternate_outlined,
                                label: 'Append photo',
                                onTap: () {},
                              ),
                              const SizedBox(height: 12),
                              _PrimaryActionButton(
                                label: 'Save follow-up',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // Update Report Section End
                        const SizedBox(height: 14),
                        // Delete Report Section Start
                        _CrudPanel(
                          title: 'Remove report',
                          subtitle:
                              'Soft-delete user reports or log moderator deletion.',
                          child: Column(
                            children: [
                              const _ReportListItem(
                                title: 'Selected report',
                                meta: 'Report ID: INC-204',
                                status: 'Owner',
                              ),
                              const SizedBox(height: 12),
                              _ReportTextField(
                                hint: 'Reason log for removal',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SecondaryActionButton(
                                      icon: Icons.archive_outlined,
                                      label: 'Soft delete',
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _DangerActionButton(
                                      label: 'Hard delete',
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Delete Report Section End
                        const SizedBox(height: 12),
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

class _StatusButton extends StatelessWidget {
  const _StatusButton({
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
          color: selected ? TutelaColors.plum : TutelaColors.canvas,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: TutelaColors.plum, width: 1.1),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: selected ? TutelaColors.canvas : TutelaColors.plum,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
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
  });

  final String title;
  final String meta;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
      ),
      child: Row(
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
        ],
      ),
    );
  }
}

class _ReportTextField extends StatelessWidget {
  const _ReportTextField({required this.hint, this.maxLines = 1});

  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
