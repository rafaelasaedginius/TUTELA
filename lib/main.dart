import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/safe_route_planner_screen.dart';
import 'screens/safety_circle_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/support_groups_screen.dart';
import 'theme/tutela_colors.dart';
import 'widgets/tutela_bottom_nav.dart';

void main() {
  runApp(const TutelaApp());
}

class TutelaApp extends StatelessWidget {
  const TutelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: TutelaColors.plum),
        scaffoldBackgroundColor: TutelaColors.ivory,
        textTheme: GoogleFonts.dmSansTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        TutelaRoutes.home: (context) => const HomeScreen(),
        TutelaRoutes.map: (context) => const HomeDashboardScreen(),
        TutelaRoutes.route: (context) => const SafeRoutePlannerScreen(),
        TutelaRoutes.circle: (context) => const SafetyCircleScreen(),
        TutelaRoutes.support: (context) => const SupportGroupsScreen(),
      },
    );
  }
}
