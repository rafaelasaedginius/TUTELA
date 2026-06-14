import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/auth_mode.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_button.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

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

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  bool get _isRegister => _mode == AuthMode.register;

  @override
  void initState() {
    super.initState();

    _mode = widget.initialMode;

    // Auth Page Animation Start
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
    // Auth Page Animation End
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                        // Auth Header Start
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
                        // Auth Header End
                        const SizedBox(height: 34),
                        // Auth Mode Switch Start
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
                        // Auth Mode Switch End
                        const SizedBox(height: 28),
                        // Login Form Start
                        FadeTransition(
                          opacity: _formOpacity,
                          child: SlideTransition(
                            position: _formOffset,
                            child: SizedBox(
                              height: _isRegister ? 478 : 286,
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
                                  child: _AuthFields(
                                    mode: _mode,
                                    usernameController: _usernameController,
                                    nameController: _nameController,
                                    emailController: _emailController,
                                    cityController: _cityController,
                                    phoneController: _phoneController,
                                    passwordController: _passwordController,
                                    confirmPasswordController:
                                        _confirmPasswordController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Login Form End
                        const SizedBox(height: 10),
                        // Auth Buttons Start
                        FadeTransition(
                          opacity: _actionsOpacity,
                          child: SlideTransition(
                            position: _actionsOffset,
                            child: Column(
                              children: [
                                TutelaButton(
                                  label: _isLoading
                                      ? 'Please wait...'
                                      : (_isRegister
                                            ? 'Create account'
                                            : 'Sign in'),
                                  width: contentWidth,
                                  backgroundColor: TutelaColors.plum,
                                  foregroundColor: TutelaColors.canvas,
                                  borderColor: TutelaColors.plum,
                                  shadowColor: TutelaColors.plum.withValues(
                                    alpha: 0.33,
                                  ),
                                  onPressed: _isLoading ? () {} : _submit,
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
                        // Auth Buttons End
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

  Future<void> _submit() async {
    if (_isRegister) {
      await _handleRegister();
    } else {
      await _handleSignIn();
    }
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final city = _cityController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        name.isEmpty ||
        email.isEmpty ||
        city.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }
    if (!RegExp(r'^[a-z0-9_]{3,20}$').hasMatch(username)) {
      _showMessage('Username must be 3-20 lowercase letters, numbers or _.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final taken = await _userService.isUsernameTaken(username);
      if (taken) {
        _showMessage('Username already taken.');
        return;
      }

      final fbUser = await _authService.register(
        email: email,
        password: password,
      );

      final now = Timestamp.now();
      final user = User(
        uid: fbUser.uid,
        username: username,
        email: email,
        name: name,
        phoneNumber: phone,
        homeCity: city,
        createdAt: now,
        updatedAt: now,
      );
      await _userService.createUser(user);

      _openHome();
    } on fb.FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Registration failed.');
    } catch (e) {
      _showMessage('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter your email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signIn(email: email, password: password);
      _openHome();
    } on fb.FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Sign in failed.');
    } catch (e) {
      _showMessage('Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
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
    // Back Button Start
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
    // Back Button End
  }
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({required this.mode, required this.onChanged});

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final isRegister = mode == AuthMode.register;

    // Auth Mode Switch Control Start
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
    // Auth Mode Switch Control End
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
  const _AuthFields({
    required this.mode,
    required this.usernameController,
    required this.nameController,
    required this.emailController,
    required this.cityController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  final AuthMode mode;
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController cityController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  bool get _isRegister => mode == AuthMode.register;

  @override
  Widget build(BuildContext context) {
    // Form Fields Start
    return Column(
      children: [
        if (_isRegister) ...[
          _TutelaTextField(
            controller: usernameController,
            label: 'Username',
            hint: 'e.g. ferzen_k',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _TutelaTextField(
            controller: nameController,
            label: 'Full name',
            hint: 'Enter your name',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
        ],
        _TutelaTextField(
          controller: emailController,
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        if (_isRegister) ...[
          const SizedBox(height: 14),
          _TutelaTextField(
            controller: cityController,
            label: 'City',
            hint: 'Your home city',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          _TutelaTextField(
            controller: phoneController,
            label: 'Phone number',
            hint: 'e.g. 0812xxxxxxx',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
        ],
        const SizedBox(height: 14),
        _PasswordTextField(
          controller: passwordController,
          label: 'Password',
          hint: _isRegister ? 'Create a password' : 'Enter your password',
          textInputAction: _isRegister
              ? TextInputAction.next
              : TextInputAction.done,
        ),
        if (_isRegister) ...[
          const SizedBox(height: 14),
          _PasswordTextField(
            controller: confirmPasswordController,
            label: 'Confirm password',
            hint: 'Repeat your password',
            textInputAction: TextInputAction.done,
          ),
        ] else ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            // Forgot Password Navigation Start
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => ForgotPasswordScreen(
                      initialEmail: emailController.text,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
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
            ),
            // Forgot Password Navigation End
          ),
        ],
      ],
    );
    // Form Fields End
  }
}

class _TutelaTextField extends StatelessWidget {
  const _TutelaTextField({
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    // Text Field Start
    return TextField(
      controller: controller,
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
        suffixIcon: suffixIcon,
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
    // Text Field End
  }
}

class _PasswordTextField extends StatefulWidget {
  const _PasswordTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputAction? textInputAction;

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Password Visibility Button Start
    return _TutelaTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      obscureText: !_passwordVisible,
      textInputAction: widget.textInputAction,
      suffixIcon: IconButton(
        tooltip: _passwordVisible ? 'Hide password' : 'Show password',
        splashRadius: 20,
        onPressed: () {
          setState(() => _passwordVisible = !_passwordVisible);
        },
        icon: Icon(
          _passwordVisible
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: TutelaColors.plum.withValues(alpha: 0.68),
          size: 20,
        ),
      ),
    );
    // Password Visibility Button End
  }
}
