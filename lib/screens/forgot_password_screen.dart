import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/auth_service.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  late final TextEditingController _emailController;

  bool _isSending = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();

    // Forgot Password Validation Start
    if (email.isEmpty) {
      _showMessage('Please enter your email address.');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }
    // Forgot Password Validation End

    setState(() => _isSending = true);
    try {
      // Firebase sends the password reset link to the supplied email.
      await _authService.sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _emailSent = true);
    } on fb.FirebaseAuthException catch (error) {
      _showMessage(_firebaseErrorMessage(error));
    } catch (_) {
      _showMessage('Could not send the reset link. Please try again.');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _firebaseErrorMessage(fb.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait before trying again.';
      case 'network-request-failed':
        return 'Please check your internet connection.';
      default:
        return error.message ?? 'Could not send the reset link.';
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final contentWidth = (size.width - 48).clamp(288.0, 360.0);

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
                        // Forgot Password Header Start
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _ForgotBackButton(
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(height: 42),
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: TutelaColors.rose.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _emailSent
                                ? Icons.mark_email_read_outlined
                                : Icons.lock_reset_rounded,
                            color: TutelaColors.plum,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          _emailSent ? 'Check your email' : 'Forgot password?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fraunces(
                            color: TutelaColors.plum,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            height: 1.05,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _emailSent
                              ? 'We sent a password reset link to ${_emailController.text.trim()}.'
                              : 'Enter your account email and we will send you a secure reset link.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: TutelaColors.plum.withValues(alpha: 0.66),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                        ),
                        // Forgot Password Header End
                        const SizedBox(height: 32),
                        if (!_emailSent) ...[
                          // Forgot Password Form Start
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.email],
                            onSubmitted: (_) {
                              if (!_isSending) _sendResetLink();
                            },
                            cursorColor: TutelaColors.plum,
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'you@example.com',
                              prefixIcon: const Icon(
                                Icons.mail_outline_rounded,
                                color: TutelaColors.plum,
                                size: 20,
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: GoogleFonts.dmSans(
                                color: TutelaColors.plum,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0,
                              ),
                              hintStyle: GoogleFonts.dmSans(
                                color: TutelaColors.plum.withValues(
                                  alpha: 0.42,
                                ),
                                fontSize: 14,
                                letterSpacing: 0,
                              ),
                              filled: true,
                              fillColor: TutelaColors.ivory.withValues(
                                alpha: 0.22,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 17,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26),
                                borderSide: BorderSide(
                                  color: TutelaColors.plum.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(26),
                                borderSide: const BorderSide(
                                  color: TutelaColors.plum,
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          TutelaButton(
                            label: _isSending
                                ? 'Sending...'
                                : 'Send reset link',
                            width: contentWidth,
                            backgroundColor: TutelaColors.plum,
                            foregroundColor: TutelaColors.canvas,
                            borderColor: TutelaColors.plum,
                            shadowColor: TutelaColors.plum.withValues(
                              alpha: 0.28,
                            ),
                            onPressed: _isSending ? () {} : _sendResetLink,
                          ),
                          // Forgot Password Form End
                        ] else ...[
                          // Forgot Password Success Actions Start
                          TutelaButton(
                            label: 'Back to sign in',
                            width: contentWidth,
                            backgroundColor: TutelaColors.plum,
                            foregroundColor: TutelaColors.canvas,
                            borderColor: TutelaColors.plum,
                            shadowColor: TutelaColors.plum.withValues(
                              alpha: 0.28,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isSending ? null : _sendResetLink,
                            child: Text(
                              _isSending ? 'Sending...' : 'Send link again',
                              style: GoogleFonts.dmSans(
                                color: TutelaColors.plum,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: TutelaColors.plum,
                              ),
                            ),
                          ),
                          // Forgot Password Success Actions End
                        ],
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

class _ForgotBackButton extends StatelessWidget {
  const _ForgotBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Back to sign in',
      onPressed: onTap,
      icon: const Icon(Icons.arrow_back_rounded),
      color: TutelaColors.plum,
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: TutelaColors.canvas,
        side: BorderSide(color: TutelaColors.plum.withValues(alpha: 0.14)),
        shadowColor: TutelaColors.plum.withValues(alpha: 0.12),
        elevation: 3,
      ),
    );
  }
}
