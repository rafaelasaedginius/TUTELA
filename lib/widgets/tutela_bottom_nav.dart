import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';

enum TutelaNavTab { map, route, home, circle, support }

class TutelaRoutes {
  static const home = '/home';
  static const map = '/map';
  static const route = '/route';
  static const circle = '/circle';
  static const support = '/support';
}

class TutelaBottomNav extends StatelessWidget {
  const TutelaBottomNav({super.key, required this.selected});

  final TutelaNavTab selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: TutelaColors.canvas,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomNavItem(
            icon: Icons.map_rounded,
            label: 'Map',
            selected: selected == TutelaNavTab.map,
            onTap: () => _goTo(context, TutelaRoutes.map),
          ),
          _BottomNavItem(
            icon: Icons.route_rounded,
            label: 'Route',
            selected: selected == TutelaNavTab.route,
            onTap: () => _goTo(context, TutelaRoutes.route),
          ),
          _BottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: selected == TutelaNavTab.home,
            onTap: () => _goTo(context, TutelaRoutes.home),
          ),
          _BottomNavItem(
            icon: Icons.groups_2_outlined,
            label: 'Circle',
            selected: selected == TutelaNavTab.circle,
            onTap: () => _goTo(context, TutelaRoutes.circle),
          ),
          _BottomNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Support',
            selected: selected == TutelaNavTab.support,
            onTap: () => _goTo(context, TutelaRoutes.support),
          ),
        ],
      ),
    );
  }

  void _goTo(BuildContext context, String routeName) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == routeName) return;
    Navigator.of(context).pushReplacementNamed(routeName);
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? TutelaColors.plum
        : TutelaColors.plum.withValues(alpha: 0.45);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selected ? null : onTap,
      child: SizedBox(
        width: 52,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
