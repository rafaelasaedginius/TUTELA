import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';
import 'home_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                // Home Header Start
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Home',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Your safety overview for today.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.68),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HomeIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
                // Home Header End
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Safety Summary Card Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: TutelaColors.plum,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: TutelaColors.plum.withValues(
                                  alpha: 0.22,
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
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: TutelaColors.canvas.withValues(
                                        alpha: 0.16,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shield_outlined,
                                      color: TutelaColors.canvas,
                                      size: 23,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'You are in a calm area',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.canvas,
                                        fontSize: 17,
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
                                'No high-alert incident reports nearby. Keep your safety circle updated before you travel.',
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
                        // Safety Summary Card End
                        const SizedBox(height: 16),
                        // Quick Actions Start
                        Row(
                          children: [
                            Expanded(
                              child: _HomeActionCard(
                                icon: Icons.route_rounded,
                                title: 'Safe Route',
                                subtitle: 'Plan trip',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HomeActionCard(
                                icon: Icons.add_location_alt_outlined,
                                title: 'Report',
                                subtitle: 'Share alert',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _HomeActionCard(
                                icon: Icons.groups_2_outlined,
                                title: 'Circle',
                                subtitle: '3 contacts',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _HomeActionCard(
                                icon: Icons.sos_rounded,
                                title: 'SOS',
                                subtitle: 'Emergency',
                                onTap: () {},
                                important: true,
                              ),
                            ),
                          ],
                        ),
                        // Quick Actions End
                        const SizedBox(height: 16),
                        // Map Preview Card Start
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _openMap(context),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: TutelaColors.ivory.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: TutelaColors.plum.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: TutelaColors.rose.withValues(
                                      alpha: 0.18,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.map_rounded,
                                    color: TutelaColors.plum,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Open Map Dashboard',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          height: 1.15,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'View route status and nearby reports.',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum.withValues(
                                            alpha: 0.62,
                                          ),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
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
                        // Map Preview Card End
                        const SizedBox(height: 16),
                        // Recent Updates Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TutelaColors.canvas,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: TutelaColors.plum.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recent updates',
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.plum,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const _HomeUpdateRow(
                                title: 'Safety circle checked in',
                                time: '8 min ago',
                              ),
                              const SizedBox(height: 12),
                              const _HomeUpdateRow(
                                title: 'Safer route found near campus',
                                time: '24 min ago',
                              ),
                            ],
                          ),
                        ),
                        // Recent Updates End
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Bottom Navigation Start
                _HomeBottomNav(onMapTap: () => _openMap(context)),
                // Bottom Navigation End
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const HomeDashboardScreen(),
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.important = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool important;

  @override
  Widget build(BuildContext context) {
    final iconBackground = important
        ? TutelaColors.plum
        : TutelaColors.peach.withValues(alpha: 0.28);
    final iconColor = important ? TutelaColors.canvas : TutelaColors.plum;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 122,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum.withValues(alpha: 0.58),
                fontSize: 12,
                fontWeight: FontWeight.w400,
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

class _HomeUpdateRow extends StatelessWidget {
  const _HomeUpdateRow({required this.title, required this.time});

  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: const BoxDecoration(
            color: TutelaColors.rose,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
        Text(
          time,
          style: GoogleFonts.dmSans(
            color: TutelaColors.plum.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _HomeIconButton extends StatelessWidget {
  const _HomeIconButton({required this.icon, required this.onTap});

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

class _HomeBottomNav extends StatelessWidget {
  const _HomeBottomNav({required this.onMapTap});

  final VoidCallback onMapTap;

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
          _HomeBottomNavItem(
            icon: Icons.map_rounded,
            label: 'Map',
            selected: false,
            onTap: onMapTap,
          ),
          const _HomeBottomNavItem(
            icon: Icons.route_rounded,
            label: 'Route',
            selected: false,
          ),
          const _HomeBottomNavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: true,
          ),
          const _HomeBottomNavItem(
            icon: Icons.groups_2_outlined,
            label: 'Circle',
            selected: false,
          ),
          const _HomeBottomNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            selected: false,
          ),
        ],
      ),
    );
  }
}

class _HomeBottomNavItem extends StatelessWidget {
  const _HomeBottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? TutelaColors.plum
        : TutelaColors.plum.withValues(alpha: 0.45);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}
