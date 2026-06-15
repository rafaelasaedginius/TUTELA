import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/auth_service.dart';
import '../services/cloudinary_service.dart';
import '../services/user_service.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';
import 'splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _userService = UserService();
  final _cloudinaryService = CloudinaryService();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _homeCityController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  User? _user;
  bool _loading = true;
  bool _saving = false;
  bool _savingPassword = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _homeCityController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final user = await _userService.getUser(uid);
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
      if (user != null) {
        _nameController.text = user.name;
        _usernameController.text = user.username;
        _phoneController.text = user.phoneNumber;
        _homeCityController.text = user.homeCity ?? '';
        _emailController.text = user.email;
      }
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: TutelaColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: TutelaColors.plum.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: TutelaColors.plum),
                title: Text(
                  'Take a photo',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: TutelaColors.plum),
                title: Text(
                  'Choose from gallery',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final file = File(picked.path);
      final attachment = await _cloudinaryService.uploadImage(file);
      final uid = _authService.currentUser!.uid;
      await _userService.updateUser(uid, {'avatar': attachment.toMap()});
      await _loadUser();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload avatar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _saveProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await _userService.updateUser(uid, {
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'homeCity': _homeCityController.text.trim(),
      });
      await _loadUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated.')),
        );
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields.')),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }
    if (next.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    setState(() => _savingPassword = true);
    try {
      await _authService.changePassword(currentPassword: current, newPassword: next);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully.')),
        );
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update password: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TutelaColors.canvas,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Log out?',
          style: GoogleFonts.fraunces(
            color: TutelaColors.plum,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Do you want to log out?',
          style: GoogleFonts.dmSans(
            color: TutelaColors.plum.withValues(alpha: 0.72),
            fontSize: 14,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log out',
              style: GoogleFonts.dmSans(
                color: TutelaColors.rose,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseCrashlytics.instance.setUserIdentifier('');
    await _authService.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => const _DeleteAccountDialog(),
    );
    if (password == null || password.isEmpty) return;
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final navigator = Navigator.of(context);
    try {
      await _authService.deleteAccount(currentPassword: password);
      await _userService.deleteUserCascade(uid);
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e')),
        );
      }
    }
  }

  String _initials() {
    final name = _user?.name ?? '';
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

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
                Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: TutelaColors.rose.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: TutelaColors.plum,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 31,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Account and safety preferences.',
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.58),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _confirmLogout,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: TutelaColors.ivory.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: TutelaColors.plum.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: TutelaColors.plum,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: TutelaColors.plum,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: TutelaColors.plum.withValues(alpha: 0.2),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _uploadingAvatar ? null : _pickAndUploadAvatar,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 72,
                                            height: 72,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: TutelaColors.canvas.withValues(alpha: 0.16),
                                              shape: BoxShape.circle,
                                            ),
                                            child: _uploadingAvatar
                                                ? const SizedBox(
                                                    width: 26,
                                                    height: 26,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.4,
                                                    ),
                                                  )
                                                : _user?.avatar != null
                                                    ? ClipOval(
                                                        child: Image.network(
                                                          _user!.avatar!.secureUrl,
                                                          width: 72,
                                                          height: 72,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : Text(
                                                        _initials(),
                                                        style: GoogleFonts.fraunces(
                                                          color: TutelaColors.canvas,
                                                          fontSize: 28,
                                                          fontWeight: FontWeight.w600,
                                                          height: 1,
                                                          letterSpacing: 0,
                                                        ),
                                                      ),
                                          ),
                                          Positioned(
                                            right: -2,
                                            bottom: -2,
                                            child: Container(
                                              width: 28,
                                              height: 28,
                                              decoration: const BoxDecoration(
                                                color: TutelaColors.canvas,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt_outlined,
                                                color: TutelaColors.plum,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _user?.name.isNotEmpty == true ? _user!.name : '—',
                                            style: GoogleFonts.dmSans(
                                              color: TutelaColors.canvas,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              height: 1.1,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _user?.email ?? '',
                                            style: GoogleFonts.dmSans(
                                              color: TutelaColors.canvas.withValues(alpha: 0.8),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              height: 1.15,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                          if (_user?.homeCity != null && _user!.homeCity!.isNotEmpty) ...[
                                            const SizedBox(height: 10),
                                            Text(
                                              'Home city: ${_user!.homeCity}',
                                              style: GoogleFonts.dmSans(
                                                color: TutelaColors.canvas.withValues(alpha: 0.72),
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                height: 1,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _ProfilePanel(
                                title: 'Personal data',
                                subtitle: 'Update your public account information.',
                                child: Column(
                                  children: [
                                    _ProfileTextField(
                                      hint: 'Full name',
                                      controller: _nameController,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProfileTextField(
                                      hint: 'Username',
                                      controller: _usernameController,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProfileTextField(
                                      hint: 'Phone number',
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProfileTextField(
                                      hint: 'Home city',
                                      controller: _homeCityController,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProfileTextField(
                                      hint: 'Email address',
                                      controller: _emailController,
                                      enabled: false,
                                    ),
                                    const SizedBox(height: 14),
                                    _PrimaryProfileButton(
                                      label: _saving ? 'Saving…' : 'Save profile',
                                      onTap: _saving ? () {} : _saveProfile,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _ProfilePanel(
                                title: 'Account security',
                                subtitle: 'Change your password.',
                                child: Column(
                                  children: [
                                    _ProfilePasswordField(
                                      hint: 'Current password',
                                      controller: _currentPasswordController,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProfilePasswordField(
                                      hint: 'New password',
                                      controller: _newPasswordController,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProfilePasswordField(
                                      hint: 'Confirm new password',
                                      controller: _confirmPasswordController,
                                    ),
                                    const SizedBox(height: 14),
                                    _PrimaryProfileButton(
                                      label: _savingPassword ? 'Updating…' : 'Update password',
                                      onTap: _savingPassword ? () {} : _changePassword,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              _DangerProfileButton(
                                label: 'Delete account',
                                onTap: _confirmDeleteAccount,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                const TutelaBottomNav(selected: TutelaNavTab.profile),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatelessWidget {
  const _ProfilePanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TutelaColors.canvas,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.62),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.enabled = true,
    this.keyboardType,
  });

  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool enabled;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      cursorColor: TutelaColors.plum,
      style: GoogleFonts.dmSans(
        color: enabled
            ? TutelaColors.plum
            : TutelaColors.plum.withValues(alpha: 0.42),
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          color: TutelaColors.plum.withValues(alpha: 0.42),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        filled: true,
        fillColor: enabled
            ? TutelaColors.ivory.withValues(alpha: 0.2)
            : TutelaColors.ivory.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        suffixIcon: suffixIcon,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: TutelaColors.plum.withValues(alpha: 0.08),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: TutelaColors.plum.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: TutelaColors.plum, width: 1.4),
        ),
      ),
    );
  }
}

class _ProfilePasswordField extends StatefulWidget {
  const _ProfilePasswordField({required this.hint, this.controller});

  final String hint;
  final TextEditingController? controller;

  @override
  State<_ProfilePasswordField> createState() => _ProfilePasswordFieldState();
}

class _ProfilePasswordFieldState extends State<_ProfilePasswordField> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return _ProfileTextField(
      hint: widget.hint,
      controller: widget.controller,
      obscureText: !_passwordVisible,
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
  }
}

class _PrimaryProfileButton extends StatelessWidget {
  const _PrimaryProfileButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.plum,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.canvas,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _DangerProfileButton extends StatelessWidget {
  const _DangerProfileButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.rose.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: TutelaColors.rose, width: 1.3),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.rose,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: TutelaColors.canvas,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        'Delete account?',
        style: GoogleFonts.fraunces(
          color: TutelaColors.plum,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This action is permanent. Your account and all data will be deleted and cannot be recovered.',
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.72),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: _obscure,
            cursorColor: TutelaColors.plum,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password to confirm',
              hintStyle: GoogleFonts.dmSans(
                color: TutelaColors.plum.withValues(alpha: 0.42),
                fontSize: 14,
              ),
              filled: true,
              fillColor: TutelaColors.ivory.withValues(alpha: 0.2),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                splashRadius: 18,
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: TutelaColors.plum.withValues(alpha: 0.6),
                  size: 20,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    BorderSide(color: TutelaColors.plum.withValues(alpha: 0.14)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: TutelaColors.plum, width: 1.4),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(
            'Delete',
            style: GoogleFonts.dmSans(
              color: TutelaColors.rose,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}