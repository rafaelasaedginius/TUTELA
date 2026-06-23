import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/maps_debug_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/safe_route_planner_screen.dart';
import 'screens/safety_circle_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/tutela_colors.dart';
import 'widgets/tutela_bottom_nav.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Notification harus diinisialisasi setelah Firebase karena listener-nya
  // membaca Firebase Auth dan Cloud Firestore.
  await NotificationService.initialize();

  FlutterNativeSplash.remove();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught async errors outside of the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const TutelaApp());
}

class TutelaApp extends StatelessWidget {
  const TutelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Global navigator key dipakai saat notification ditekan, karena callback
      // notification tidak memiliki BuildContext dari sebuah screen.
      navigatorKey: NotificationService.navigatorKey,
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
        TutelaRoutes.profile: (context) => const ProfileScreen(),
        '/maps-debug': (context) => const MapsDebugScreen(),
      },
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NotificationService.openPendingIncidentIfNeeded();
        });
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
