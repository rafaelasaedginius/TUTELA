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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerOffset;
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

    _headerOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
    );
    _headerOffset =
        Tween<Offset>(begin: const Offset(0, -0.28), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
          ),
        );
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final widthScale = (size.width / 402).clamp(0.88, 1.1);
    final contentWidth = (size.width - 56).clamp(280.0, 318.0);

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Top Label Start
                Positioned(
                  top: 47,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _headerOpacity,
                    child: SlideTransition(
                      position: _headerOffset,
                      child: Text(
                        'Getting started',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: TutelaColors.plum,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                // Top Label End
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
