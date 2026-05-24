import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';
import 'report_incident_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

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
                // Dashboard Top Bar Start
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, Rafaela',
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
                          'Plan a safer route today.',
                          style: GoogleFonts.dmSans(
                            color: TutelaColors.plum.withValues(alpha: 0.72),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _IconCircleButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
                // Dashboard Top Bar End
                const SizedBox(height: 18),
                // Search Bar Start
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: TutelaColors.ivory.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: TutelaColors.plum.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: TutelaColors.plum.withValues(alpha: 0.72),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Search destination',
                        style: GoogleFonts.dmSans(
                          color: TutelaColors.plum.withValues(alpha: 0.48),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search Bar End
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      // Map Preview Start
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: const _SimpleMapPreview(),
                        ),
                      ),
                      // Map Preview End
                      // Map Control Buttons Start
                      Positioned(
                        top: 16,
                        right: 14,
                        child: Column(
                          children: [
                            _IconCircleButton(
                              icon: Icons.my_location_rounded,
                              onTap: () {},
                            ),
                            const SizedBox(height: 10),
                            _IconCircleButton(
                              icon: Icons.layers_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      // Map Control Buttons End
                      // Safety Status Card Start
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 88,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TutelaColors.canvas,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: TutelaColors.plum.withValues(
                                  alpha: 0.14,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: TutelaColors.peach.withValues(
                                    alpha: 0.34,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: TutelaColors.plum,
                                  size: 23,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Safer route available',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.1,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Low reports nearby - 12 min',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum.withValues(
                                          alpha: 0.62,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.15,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: TutelaColors.plum,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Safety Status Card End
                      // Dashboard Quick Actions Start
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 18,
                        child: Row(
                          children: [
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
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dashboard Quick Actions End
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Bottom Navigation Start
                Container(
                  height: 66,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: TutelaColors.canvas,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: TutelaColors.plum.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: TutelaColors.plum.withValues(alpha: 0.1),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BottomNavItem(
                        icon: Icons.map_rounded,
                        label: 'Map',
                        selected: true,
                      ),
                      _BottomNavItem(
                        icon: Icons.route_rounded,
                        label: 'Route',
                        selected: false,
                      ),
                      _BottomNavItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        selected: false,
                      ),
                      _BottomNavItem(
                        icon: Icons.groups_2_outlined,
                        label: 'Circle',
                        selected: false,
                      ),
                      _BottomNavItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        selected: false,
                      ),
                    ],
                  ),
                ),
                // Bottom Navigation End
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
        builder: (context) => const ReportIncidentScreen(),
      ),
    );
  }
}

class _SimpleMapPreview extends StatelessWidget {
  const _SimpleMapPreview();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MapPreviewPainter(),
      child: Stack(
        children: [
          Positioned(
            left: 70,
            top: 112,
            child: _MapPin(
              color: TutelaColors.rose,
              icon: Icons.priority_high_rounded,
            ),
          ),
          Positioned(
            right: 58,
            top: 170,
            child: _MapPin(
              color: TutelaColors.plum,
              icon: Icons.person_pin_circle_rounded,
            ),
          ),
          Positioned(
            left: 122,
            bottom: 170,
            child: _MapPin(
              color: TutelaColors.peach,
              icon: Icons.shield_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..color = TutelaColors.ivory.withValues(alpha: 0.3);
    canvas.drawRect(Offset.zero & size, background);

    final minorRoad = Paint()
      ..color = TutelaColors.rose.withValues(alpha: 0.16)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final majorRoad = Paint()
      ..color = TutelaColors.plum.withValues(alpha: 0.12)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;
    final route = Paint()
      ..color = TutelaColors.plum
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.18),
      Offset(size.width * 0.9, size.height * 0.04),
      minorRoad,
    );
    canvas.drawLine(
      Offset(size.width * 0.04, size.height * 0.54),
      Offset(size.width * 0.94, size.height * 0.38),
      majorRoad,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.86),
      Offset(size.width * 0.98, size.height * 0.72),
      minorRoad,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.12, size.height),
      minorRoad,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.58, size.height),
      majorRoad,
    );

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.7)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.56,
        size.width * 0.56,
        size.height * 0.54,
        size.width * 0.68,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.32,
        size.width * 0.68,
        size.height * 0.26,
        size.width * 0.82,
        size.height * 0.2,
      );
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: TutelaColors.canvas, size: 20),
    );
  }
}

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
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
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
              color: TutelaColors.plum.withValues(alpha: filled ? 0.22 : 0.12),
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
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: foreground,
                fontSize: 14,
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

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? TutelaColors.plum
        : TutelaColors.plum.withValues(alpha: 0.45);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 21),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: color,
            fontSize: 10.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
