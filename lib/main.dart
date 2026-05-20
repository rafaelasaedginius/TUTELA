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

enum AuthMode { signIn, register }

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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.initialMode});

  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AuthMode _mode;
  late final AnimationController _controller;
  late final Animation<double> _brandOpacity;
  late final Animation<Offset> _brandOffset;
  late final Animation<double> _switchOpacity;
  late final Animation<Offset> _switchOffset;
  late final Animation<double> _formOpacity;
  late final Animation<Offset> _formOffset;
  late final Animation<double> _actionsOpacity;
  late final Animation<Offset> _actionsOffset;

  bool get _isRegister => _mode == AuthMode.register;

  @override
  void initState() {
    super.initState();

    _mode = widget.initialMode;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..forward();
    _brandOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.46, curve: Curves.easeOutCubic),
    );
    _brandOffset = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.52, curve: Curves.easeOutCubic),
          ),
        );
    _switchOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.16, 0.62, curve: Curves.easeOutCubic),
    );
    _switchOffset =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.16, 0.68, curve: Curves.easeOutCubic),
          ),
        );
    _formOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.78, curve: Curves.easeOutCubic),
    );
    _formOffset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.82, curve: Curves.easeOutCubic),
          ),
        );
    _actionsOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 1, curve: Curves.easeOutCubic),
    );
    _actionsOffset =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.48, 1, curve: Curves.easeOutCubic),
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
    final contentWidth = (size.width - 48).clamp(288.0, 340.0);
    final brandScale = (size.width / 402).clamp(0.9, 1.08);

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                24,
                18,
                24,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 42,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeTransition(
                          opacity: _brandOpacity,
                          child: SlideTransition(
                            position: _brandOffset,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _BackButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Text(
                                  'Tutela',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.fraunces(
                                    color: TutelaColors.plum,
                                    fontSize: 50 * brandScale,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 340),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: Text(
                                    _isRegister
                                        ? 'Create your safe-space account.'
                                        : 'Welcome back to your safe routes.',
                                    key: ValueKey(_mode),
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      color: TutelaColors.plum,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      height: 1.25,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        FadeTransition(
                          opacity: _switchOpacity,
                          child: SlideTransition(
                            position: _switchOffset,
                            child: _AuthModeSwitch(
                              mode: _mode,
                              onChanged: (mode) {
                                setState(() {
                                  _mode = mode;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FadeTransition(
                          opacity: _formOpacity,
                          child: SlideTransition(
                            position: _formOffset,
                            child: SizedBox(
                              height: 286,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 360),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Align(
                                  key: ValueKey(_mode),
                                  alignment: Alignment.topCenter,
                                  child: _AuthFields(mode: _mode),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _actionsOpacity,
                          child: SlideTransition(
                            position: _actionsOffset,
                            child: Column(
                              children: [
                                TutelaButton(
                                  label: _isRegister
                                      ? 'Create account'
                                      : 'Sign in',
                                  width: contentWidth,
                                  backgroundColor: TutelaColors.plum,
                                  foregroundColor: TutelaColors.canvas,
                                  borderColor: TutelaColors.plum,
                                  shadowColor: TutelaColors.plum.withValues(
                                    alpha: 0.33,
                                  ),
                                  onPressed: () {},
                                ),
                                const SizedBox(height: 18),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _mode = _isRegister
                                          ? AuthMode.signIn
                                          : AuthMode.register;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 4,
                                    ),
                                    child: Text.rich(
                                      TextSpan(
                                        text: _isRegister
                                            ? 'Already have an account? '
                                            : 'New here? ',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.2,
                                          letterSpacing: 0,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: _isRegister
                                                ? 'Sign in.'
                                                : 'Create an Account.',
                                            style: GoogleFonts.dmSans(
                                              color: TutelaColors.plum,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  TutelaColors.plum,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              height: 1.2,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TutelaColors.canvas,
            shape: BoxShape.circle,
            border: Border.all(
              color: TutelaColors.plum.withValues(alpha: 0.18),
            ),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: TutelaColors.plum,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isRegister = mode == AuthMode.register;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.12)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isRegister
                ? Alignment.centerRight
                : Alignment.centerLeft,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: TutelaColors.plum,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: TutelaColors.plum.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _AuthModeOption(
                  label: 'Sign in',
                  selected: !isRegister,
                  onTap: () => onChanged(AuthMode.signIn),
                ),
              ),
              Expanded(
                child: _AuthModeOption(
                  label: 'Register',
                  selected: isRegister,
                  onTap: () => onChanged(AuthMode.register),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthModeOption extends StatelessWidget {
  const _AuthModeOption({
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
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: GoogleFonts.dmSans(
            color: selected ? TutelaColors.canvas : TutelaColors.plum,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: 0,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _AuthFields extends StatelessWidget {
  const _AuthFields({required this.mode});

  final AuthMode mode;

  bool get _isRegister => mode == AuthMode.register;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isRegister) ...[
          const _TutelaTextField(
            label: 'Full name',
            hint: 'Enter your name',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
        ],
        const _TutelaTextField(
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        _TutelaTextField(
          label: 'Password',
          hint: _isRegister ? 'Create a password' : 'Enter your password',
          obscureText: true,
          textInputAction: _isRegister
              ? TextInputAction.next
              : TextInputAction.done,
        ),
        if (_isRegister) ...[
          const SizedBox(height: 14),
          const _TutelaTextField(
            label: 'Confirm password',
            hint: 'Repeat your password',
            obscureText: true,
            textInputAction: TextInputAction.done,
          ),
        ] else ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Forgot password?',
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.2,
                letterSpacing: 0,
                decoration: TextDecoration.underline,
                decorationColor: TutelaColors.plum,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TutelaTextField extends StatelessWidget {
  const _TutelaTextField({
    required this.label,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      cursorColor: TutelaColors.plum,
      style: GoogleFonts.dmSans(
        color: TutelaColors.plum,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: GoogleFonts.dmSans(
          color: TutelaColors.plum,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        hintStyle: GoogleFonts.dmSans(
          color: TutelaColors.plum.withValues(alpha: 0.42),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        filled: true,
        fillColor: TutelaColors.ivory.withValues(alpha: 0.22),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(
            color: TutelaColors.plum.withValues(alpha: 0.22),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: TutelaColors.plum, width: 1.6),
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
