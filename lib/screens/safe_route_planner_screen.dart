import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';

class SafeRoutePlannerScreen extends StatefulWidget {
  const SafeRoutePlannerScreen({super.key});

  @override
  State<SafeRoutePlannerScreen> createState() => _SafeRoutePlannerScreenState();
}

class _SafeRoutePlannerScreenState extends State<SafeRoutePlannerScreen> {
  String _selectedTag = 'Well-lit';
  String _selectedSort = 'Rating';

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
                // Safe Route Header Start
                Row(
                  children: [
                    _RouteIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
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
                // Safe Route Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Save Route Section Start
                        _RoutePanel(
                          title: 'Save a route',
                          subtitle:
                              'Draw or auto-generate a path between two points.',
                          child: Column(
                            children: [
                              _RouteMapBox(),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _RouteFieldBox(
                                      label: 'From',
                                      value: 'Current location',
                                      icon: Icons.my_location_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _RouteFieldBox(
                                      label: 'To',
                                      value: 'Campus gate',
                                      icon: Icons.flag_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SectionLabel('Safety notes'),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _SelectableTag(
                                    label: 'Well-lit',
                                    selected: _selectedTag == 'Well-lit',
                                    onTap: () {
                                      setState(() {
                                        _selectedTag = 'Well-lit';
                                      });
                                    },
                                  ),
                                  _SelectableTag(
                                    label: 'Busy street',
                                    selected: _selectedTag == 'Busy street',
                                    onTap: () {
                                      setState(() {
                                        _selectedTag = 'Busy street';
                                      });
                                    },
                                  ),
                                  _SelectableTag(
                                    label: 'CCTV present',
                                    selected: _selectedTag == 'CCTV present',
                                    onTap: () {
                                      setState(() {
                                        _selectedTag = 'CCTV present';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _RouteTextField(hint: 'Name this route'),
                              const SizedBox(height: 14),
                              _PrimaryRouteButton(
                                label: 'Save route',
                                onTap: () {},
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
                                      onTap: () {
                                        setState(() {
                                          _selectedSort = 'Rating';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SortChip(
                                      label: 'Recency',
                                      selected: _selectedSort == 'Recency',
                                      onTap: () {
                                        setState(() {
                                          _selectedSort = 'Recency';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SortChip(
                                      label: 'Distance',
                                      selected: _selectedSort == 'Distance',
                                      onTap: () {
                                        setState(() {
                                          _selectedSort = 'Distance';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const _SavedRouteItem(
                                title: 'Campus evening route',
                                meta: '4.8 rating - 0.7 km away',
                                tag: 'Personal',
                                showActions: true,
                              ),
                              const SizedBox(height: 10),
                              const _SavedRouteItem(
                                title: 'Mall to station',
                                meta: '4.6 rating - community route',
                                tag: 'Shared',
                                showActions: true,
                              ),
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
          // Route Panel Header Start
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
          // Route Panel Header End
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RouteMapBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFE4F2FF).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RouteMapPainter())),
          const Positioned(
            left: 52,
            bottom: 28,
            child: _RoutePoint(icon: Icons.my_location_rounded),
          ),
          const Positioned(
            right: 58,
            top: 24,
            child: _RoutePoint(icon: Icons.flag_rounded),
          ),
        ],
      ),
    );
  }
}

class _RouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = TutelaColors.plum.withValues(alpha: 0.1)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    final route = Paint()
      ..color = const Color(0xFF337AA8)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.35),
      Offset(size.width * 0.94, size.height * 0.18),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.25, size.height),
      Offset(size.width * 0.74, 0),
      road,
    );

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.72)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.62,
        size.width * 0.46,
        size.height * 0.34,
        size.width * 0.76,
        size.height * 0.26,
      );
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: TutelaColors.plum,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: TutelaColors.canvas, size: 19),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 13,
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
  });

  final String title;
  final String meta;
  final String tag;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  color: const Color(0xFFE4F2FF),
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
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SecondaryRouteButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit tags',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SecondaryRouteButton(
                    icon: Icons.flag_outlined,
                    label: 'Flag',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DangerRouteButton(label: 'Delete', onTap: () {}),
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
  const _RouteTextField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
