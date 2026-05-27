import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';
import '../widgets/tutela_button.dart';

class SosConfirmationScreen extends StatelessWidget {
  const SosConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final contentWidth = (size.width - 32).clamp(300.0, 430.0);
    final buttonWidth = (contentWidth - 32).clamp(268.0, 398.0);

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              children: [
                const SizedBox(height: 14),
                // SOS Header Start
                Row(
                  children: [
                    _SosIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOS Confirmation',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 29,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Review before sending an emergency alert.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.68),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // SOS Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // SOS Warning Card Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: TutelaColors.canvas.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sos_rounded,
                                  color: TutelaColors.canvas,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Send emergency alert?',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.fraunces(
                                  color: TutelaColors.canvas,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  height: 1.05,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tutela will notify your safety circle and share your live location immediately.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.canvas.withValues(
                                    alpha: 0.86,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.35,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SOS Warning Card End
                        const SizedBox(height: 16),
                        // SOS Location Sharing Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TutelaColors.ivory.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: TutelaColors.plum.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: TutelaColors.peach.withValues(
                                    alpha: 0.35,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.my_location_rounded,
                                  color: TutelaColors.plum,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Live location ready',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.15,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Approx. location: Campus Gate, 80 m accuracy',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum.withValues(
                                          alpha: 0.62,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.25,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SOS Location Sharing End
                        const SizedBox(height: 16),
                        // SOS Contacts Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TutelaColors.canvas,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: TutelaColors.plum.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alert will be sent to',
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.plum,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const _SosContactRow(
                                priority: '1',
                                name: 'Mama',
                                detail: 'Primary emergency contact',
                              ),
                              const SizedBox(height: 12),
                              const _SosContactRow(
                                priority: '2',
                                name: 'Nadia',
                                detail:
                                    'Safety circle friend - linked help included',
                              ),
                              const SizedBox(height: 12),
                              const _SosContactRow(
                                priority: '3',
                                name: 'Campus Security',
                                detail: 'Local help point',
                              ),
                            ],
                          ),
                        ),
                        // SOS Contacts End
                        const SizedBox(height: 16),
                        // SOS Call Shortcut Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TutelaColors.ivory.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: TutelaColors.plum.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency call shortcut',
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.plum,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'Nadia will receive a request to help call Campus Security. You can also open the phone dialer from here.',
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.plum.withValues(
                                    alpha: 0.66,
                                  ),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _SosCallButton(
                                label: 'Call Campus Security',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // SOS Call Shortcut End
                        const SizedBox(height: 16),
                        // SOS Message Preview Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: TutelaColors.rose.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Message preview',
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.plum,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'SOS! I need help immediately.\n',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        height: 1.35,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'My location: [Share Location]\n'
                                          'Please call Campus Security now: [help phone]\n'
                                          'Send help to my location ASAP.',
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.plum.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                        height: 1.35,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // SOS Message Preview End
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // SOS Action Buttons Start
                TutelaButton(
                  label: 'Send SOS',
                  width: buttonWidth,
                  backgroundColor: TutelaColors.plum,
                  foregroundColor: TutelaColors.canvas,
                  borderColor: TutelaColors.plum,
                  shadowColor: TutelaColors.plum.withValues(alpha: 0.24),
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                TutelaButton(
                  label: 'Cancel',
                  width: buttonWidth,
                  backgroundColor: TutelaColors.canvas,
                  foregroundColor: TutelaColors.plum,
                  borderColor: TutelaColors.plum,
                  shadowColor: TutelaColors.plum.withValues(alpha: 0.12),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // SOS Action Buttons End
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SosContactRow extends StatelessWidget {
  const _SosContactRow({
    required this.priority,
    required this.name,
    required this.detail,
  });

  final String priority;
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TutelaColors.peach.withValues(alpha: 0.34),
            shape: BoxShape.circle,
          ),
          child: Text(
            priority,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.plum,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.plum.withValues(alpha: 0.58),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  height: 1.15,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SosCallButton extends StatelessWidget {
  const _SosCallButton({required this.label, required this.onTap});

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
          color: TutelaColors.canvas,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: TutelaColors.plum, width: 1.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_in_talk_outlined,
              color: TutelaColors.plum,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SosIconButton extends StatelessWidget {
  const _SosIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          shape: BoxShape.circle,
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: TutelaColors.plum, size: 21),
      ),
    );
  }
}
