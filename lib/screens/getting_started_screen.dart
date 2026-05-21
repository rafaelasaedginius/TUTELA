import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/auth_mode.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_button.dart';
import 'auth_screen.dart';

class GettingStartedScreen extends StatefulWidget {
  const GettingStartedScreen({super.key});

  @override
  State<GettingStartedScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _flowerController;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentOffset;
  late final Animation<double> _actionsOpacity;
  late final Animation<Offset> _actionsOffset;

  @override
  void initState() {
    super.initState();

    // Getting Started Animation Start
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
    _flowerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    )..repeat();

    _contentOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.72, curve: Curves.easeOutCubic),
    );
    _contentOffset =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.12, 0.72, curve: Curves.easeOutCubic),
          ),
        );
    _actionsOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.36, 1, curve: Curves.easeOutCubic),
    );
    _actionsOffset =
        Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.36, 1, curve: Curves.easeOutCubic),
          ),
        );
    // Getting Started Animation End
  }

  @override
  void dispose() {
    _controller.dispose();
    _flowerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = (size.width / 402).clamp(0.88, 1.1);
    final contentWidth = (size.width - 56).clamp(280.0, 318.0);
    final flowerScale = (size.width / 402).clamp(0.86, 1.12);

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Flower Decorations Start
                _FloatingFlower(
                  controller: _flowerController,
                  asset: 'assets/images/flower1.png',
                  leftFactor: 0.38,
                  topFactor: 0.025,
                  size: 62 * flowerScale,
                  phase: 0.1,
                  rotation: -0.1,
                ),
                _FloatingFlower(
                  controller: _flowerController,
                  asset: 'assets/images/flower2.png',
                  leftFactor: 0.15,
                  topFactor: 0.185,
                  size: 59 * flowerScale,
                  phase: 1.4,
                  rotation: -0.22,
                ),
                _FloatingFlower(
                  controller: _flowerController,
                  asset: 'assets/images/flower3.png',
                  leftFactor: 0.79,
                  topFactor: 0.155,
                  size: 49 * flowerScale,
                  phase: 2.2,
                  rotation: 0.18,
                ),
                _FloatingFlower(
                  controller: _flowerController,
                  asset: 'assets/images/flower4.png',
                  leftFactor: 0.06,
                  topFactor: 0.835,
                  size: 46 * flowerScale,
                  phase: 3.1,
                  rotation: -0.28,
                ),
                _FloatingFlower(
                  controller: _flowerController,
                  asset: 'assets/images/flower5.png',
                  leftFactor: 0.38,
                  topFactor: 0.755,
                  size: 36 * flowerScale,
                  phase: 4,
                  rotation: 0.1,
                ),
                _FloatingFlower(
                  controller: _flowerController,
                  asset: 'assets/images/flower6.png',
                  leftFactor: 0.55,
                  topFactor: 0.865,
                  size: 55 * flowerScale,
                  phase: 4.9,
                  rotation: -0.06,
                ),
                _FloatingFlower(
                  controller: _flowerController,
                  asset: 'assets/images/flower1.png',
                  leftFactor: 0.78,
                  topFactor: 0.74,
                  size: 62 * flowerScale,
                  phase: 5.5,
                  rotation: 0.16,
                ),
                // Flower Decorations End
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hero Text Start
                        FadeTransition(
                          opacity: _contentOpacity,
                          child: SlideTransition(
                            position: _contentOffset,
                            child: Column(
                              children: [
                                Text(
                                  'Tutela',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fraunces(
                                    color: TutelaColors.plum,
                                    fontSize: 52 * widthScale,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Move through the city with confidence.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    color: TutelaColors.plum,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.16,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Good for safe-route planning.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    color: TutelaColors.plum,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Hero Text End
                        const SizedBox(height: 72),
                        // Getting Started Buttons Start
                        FadeTransition(
                          opacity: _actionsOpacity,
                          child: SlideTransition(
                            position: _actionsOffset,
                            child: Column(
                              children: [
                                TutelaButton(
                                  label: 'Get started',
                                  width: contentWidth,
                                  backgroundColor: TutelaColors.plum,
                                  foregroundColor: TutelaColors.canvas,
                                  borderColor: TutelaColors.plum,
                                  shadowColor: TutelaColors.plum.withValues(
                                    alpha: 0.33,
                                  ),
                                  onPressed: () {
                                    _openAuth(context, AuthMode.register);
                                  },
                                ),
                                const SizedBox(height: 20),
                                TutelaButton(
                                  label: 'Log in',
                                  width: contentWidth,
                                  backgroundColor: TutelaColors.canvas,
                                  foregroundColor: TutelaColors.plum,
                                  borderColor: TutelaColors.plum,
                                  shadowColor: TutelaColors.plum.withValues(
                                    alpha: 0.24,
                                  ),
                                  onPressed: () {
                                    _openAuth(context, AuthMode.signIn);
                                  },
                                ),
                                const SizedBox(height: 21),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _openAuth(context, AuthMode.register);
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'New here? ',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        letterSpacing: 0,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Create an Account.',
                                          style: GoogleFonts.dmSans(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: TutelaColors.plum,
                                            color: TutelaColors.plum,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            height: 1.2,
                                            letterSpacing: 0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Getting Started Buttons End
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openAuth(BuildContext context, AuthMode mode) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) {
          return AuthScreen(initialMode: mode);
        },
        transitionDuration: const Duration(milliseconds: 560),
        reverseTransitionDuration: const Duration(milliseconds: 360),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.018),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _FloatingFlower extends StatelessWidget {
  const _FloatingFlower({
    required this.controller,
    required this.asset,
    required this.leftFactor,
    required this.topFactor,
    required this.size,
    required this.phase,
    required this.rotation,
  });

  final Animation<double> controller;
  final String asset;
  final double leftFactor;
  final double topFactor;
  final double size;
  final double phase;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Positioned(
      left: screenSize.width * leftFactor,
      top: screenSize.height * topFactor,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final wave = math.sin((controller.value * math.pi * 2) + phase);
          final drift = math.cos((controller.value * math.pi * 2) + phase);

          return Transform.translate(
            offset: Offset(drift * 2.2, wave * 5.2),
            child: Transform.rotate(
              angle: rotation + (wave * 0.025),
              child: child,
            ),
          );
        },
        // Flower Image With Shadow Start
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 5,
              top: 7,
              child: Opacity(
                opacity: 0.26,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2B1230),
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      asset,
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
          ],
        ),
        // Flower Image With Shadow End
      ),
    );
  }
}
