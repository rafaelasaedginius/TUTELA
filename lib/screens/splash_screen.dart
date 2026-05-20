import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';
import 'getting_started_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _referenceWidth = 402.0;
  late final AnimationController _controller;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleOffset;
  late final Animation<double> _subtitleReveal;
  late final Animation<double> _exitBlur;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    // Splash Animation Start
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 3300),
          )
          ..forward()
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && mounted) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder<void>(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const GettingStartedScreen();
                  },
                  transitionDuration: const Duration(milliseconds: 450),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                ),
              );
            }
          });

    _titleOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.22, curve: Curves.easeOutCubic),
    );
    _titleOffset = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.25, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.58, curve: Curves.easeOutQuart),
    );
    _exitBlur = Tween<double>(begin: 0, end: 14).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 1, curve: Curves.easeInOutCubic),
      ),
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1, curve: Curves.easeInOutCubic),
      ),
    );
    // Splash Animation End
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = (size.width / _referenceWidth).clamp(0.82, 1.12);
    final textStyle = GoogleFonts.fraunces(
      color: TutelaColors.plum,
      fontSize: 49 * scale,
      fontWeight: FontWeight.w600,
      height: 1.26,
      letterSpacing: 0,
    );

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _exitOpacity.value,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _exitBlur.value,
                    sigmaY: _exitBlur.value,
                  ),
                  child: child,
                ),
              );
            },
            child: Semantics(
              label: 'Tutela, is with you',
              child: ExcludeSemantics(
                // Splash Text Start
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleOffset,
                        child: Text('Tutela,', style: textStyle),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _subtitleReveal,
                      builder: (context, child) {
                        return ClipRect(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            widthFactor: _subtitleReveal.value,
                            child: child,
                          ),
                        );
                      },
                      child: Text('is with you', style: textStyle),
                    ),
                  ],
                ),
                // Splash Text End
              ),
            ),
          ),
        ),
      ),
    );
  }
}
