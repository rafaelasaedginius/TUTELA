import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({
    super.key,
    required this.title,
    required this.location,
    required this.severity,
    required this.status,
  });

  final String title;
  final String location;
  final String severity;
  final String status;

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
                // Incident Detail Header Start
                Row(
                  children: [
                    _DetailIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Incident detail',
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
                            'Full report information',
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.6),
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
                // Incident Detail Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Incident Summary Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: TutelaColors.plum,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: TutelaColors.plum.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: TutelaColors.canvas.withValues(
                                        alpha: 0.16,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
                                      color: TutelaColors.canvas,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.canvas,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1.15,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Reported near $location. This detail page is used to read the full report, review status, and continue update/delete actions.',
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.canvas.withValues(
                                    alpha: 0.86,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.35,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Incident Summary End
                        const SizedBox(height: 14),
                        // Detail Status Row Start
                        Row(
                          children: [
                            Expanded(
                              child: _DetailInfoCard(
                                label: 'Severity',
                                value: severity,
                                icon: Icons.speed_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DetailInfoCard(
                                label: 'Status',
                                value: status,
                                icon: Icons.task_alt_rounded,
                              ),
                            ),
                          ],
                        ),
                        // Detail Status Row End
                        const SizedBox(height: 14),
                        // Detail Location Start
                        _DetailPanel(
                          title: 'Pinned location',
                          child: Column(
                            children: [
                              Container(
                                height: 116,
                                decoration: BoxDecoration(
                                  color: TutelaColors.ivory.withValues(
                                    alpha: 0.32,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: TutelaColors.plum.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _DetailMapPainter(),
                                      ),
                                    ),
                                    const Center(
                                      child: Icon(
                                        Icons.location_on_rounded,
                                        color: TutelaColors.rose,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              _DetailTextLine(
                                icon: Icons.place_outlined,
                                text: location,
                              ),
                            ],
                          ),
                        ),
                        // Detail Location End
                        const SizedBox(height: 14),
                        // Detail Photos Start
                        _DetailPanel(
                          title: 'Attached photos',
                          child: const Row(
                            children: [
                              _PhotoPreview(index: '1'),
                              SizedBox(width: 10),
                              _PhotoPreview(index: '2'),
                              SizedBox(width: 10),
                              _PhotoPreview(index: '3'),
                            ],
                          ),
                        ),
                        // Detail Photos End
                        const SizedBox(height: 14),
                        // Detail Follow Up Start
                        _DetailPanel(
                          title: 'Follow-up history',
                          child: Column(
                            children: const [
                              _TimelineItem(
                                title: 'Report created',
                                detail: 'Initial report submitted by user.',
                              ),
                              SizedBox(height: 12),
                              _TimelineItem(
                                title: 'Moderator reviewed',
                                detail: 'Marked as visible on community map.',
                              ),
                            ],
                          ),
                        ),
                        // Detail Follow Up End
                        const SizedBox(height: 14),
                        // Detail Actions Start
                        Row(
                          children: [
                            Expanded(
                              child: _DetailActionButton(
                                label: 'Add follow-up',
                                icon: Icons.edit_note_rounded,
                                filled: true,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DetailActionButton(
                                label: 'Remove',
                                icon: Icons.delete_outline_rounded,
                                filled: false,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        // Detail Actions End
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

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TutelaColors.canvas,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
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
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TutelaColors.plum, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 15,
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

class _DetailTextLine extends StatelessWidget {
  const _DetailTextLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: TutelaColors.plum, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.index});

  final String index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: TutelaColors.peach.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              color: TutelaColors.plum,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              'Photo $index',
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum.withValues(alpha: 0.65),
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

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: TutelaColors.rose,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.plum,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.plum.withValues(alpha: 0.62),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
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
    final foreground = filled ? TutelaColors.canvas : TutelaColors.rose;
    final border = filled ? TutelaColors.plum : TutelaColors.rose;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: foreground,
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

class _DetailIconButton extends StatelessWidget {
  const _DetailIconButton({required this.icon, required this.onTap});

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

class _DetailMapPainter extends CustomPainter {
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
      Offset(size.width * 0.08, size.height * 0.25),
      Offset(size.width * 0.9, size.height * 0.14),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height),
      Offset(size.width * 0.72, 0),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.14, size.height * 0.74),
      Offset(size.width * 0.86, size.height * 0.46),
      route,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
