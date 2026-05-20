import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    );
  }
}

class TutelaColors {
  static const plum = Color(0xFF5D1C6A);
  static const rose = Color(0xFFCA5995);
  static const peach = Color(0xFFFFB090);
  static const ivory = Color(0xFFFFF1D3);
  static const canvas = Color(0xFFFFFFFF);
}

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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        const SizedBox(height: 72),
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
                                  onPressed: () {},
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
                                  onPressed: () {},
                                ),
                                const SizedBox(height: 21),
                                Text.rich(
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
                                          decoration: TextDecoration.underline,
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
                              ],
                            ),
                          ),
                        ),
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
}

class TutelaButton extends StatefulWidget {
  const TutelaButton({
    super.key,
    required this.label,
    required this.width,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.onPressed,
  });

  final String label;
  final double width;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color shadowColor;
  final VoidCallback onPressed;

  @override
  State<TutelaButton> createState() => _TutelaButtonState();
}

class _TutelaButtonState extends State<TutelaButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? 0.975 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            width: widget.width,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(27),
              border: Border.all(color: widget.borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: widget.shadowColor,
                  blurRadius: _isPressed ? 6 : 11,
                  spreadRadius: _isPressed ? 0 : 0.3,
                  offset: Offset(0, _isPressed ? 2 : 5),
                ),
              ],
            ),
            child: Text(
              widget.label,
              style: GoogleFonts.dmSans(
                color: widget.foregroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
