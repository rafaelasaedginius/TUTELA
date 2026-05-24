import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';

class SafetyCircleScreen extends StatefulWidget {
  const SafetyCircleScreen({super.key});

  @override
  State<SafetyCircleScreen> createState() => _SafetyCircleScreenState();
}

class _SafetyCircleScreenState extends State<SafetyCircleScreen> {
  String _priority = '1st';

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
                // Safety Circle Header Start
                Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F7EE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.groups_2_outlined,
                        color: Color(0xFF3C8B68),
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency contacts',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Personal safety layer',
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
                  ],
                ),
                // Safety Circle Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Add Contact Section Start
                        _CirclePanel(
                          title: 'Add contact',
                          subtitle:
                              'Save name, phone, relationship, and alert priority.',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _CircleTextField(hint: 'Full name'),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _CircleTextField(hint: 'Phone'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _CircleTextField(hint: 'Relationship'),
                              const SizedBox(height: 14),
                              _SectionLabel('Priority rank'),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Expanded(
                                    child: _PriorityButton(
                                      label: '1st',
                                      selected: _priority == '1st',
                                      onTap: () {
                                        setState(() {
                                          _priority = '1st';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _PriorityButton(
                                      label: '2nd',
                                      selected: _priority == '2nd',
                                      onTap: () {
                                        setState(() {
                                          _priority = '2nd';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _PriorityButton(
                                      label: '3rd',
                                      selected: _priority == '3rd',
                                      onTap: () {
                                        setState(() {
                                          _priority = '3rd';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _CircleTextField(
                                hint: 'Optional police station or helpline',
                              ),
                              const SizedBox(height: 14),
                              _PrimaryCircleButton(
                                label: 'Save contact',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // Add Contact Section End
                        const SizedBox(height: 14),
                        // Contact List Section Start
                        _CirclePanel(
                          title: 'View contact list',
                          subtitle:
                              'Sorted by priority with last-pinged status.',
                          child: Column(
                            children: [
                              const _ContactListItem(
                                name: 'Mama',
                                detail: '1st alert - pinged 4 min ago',
                                relation: 'Family',
                                showActions: true,
                              ),
                              const SizedBox(height: 10),
                              const _ContactListItem(
                                name: 'Nadia',
                                detail: '2nd alert - pinged yesterday',
                                relation: 'Friend',
                                showActions: true,
                              ),
                              const SizedBox(height: 10),
                              const _ContactListItem(
                                name: 'Campus Security',
                                detail: '3rd alert - local helpline',
                                relation: 'Help',
                                showActions: true,
                              ),
                              const SizedBox(height: 14),
                              _PrimaryCircleButton(
                                label: 'Send SOS alert chain',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // Contact List Section End
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Bottom Navigation Start
                const TutelaBottomNav(selected: TutelaNavTab.circle),
                // Bottom Navigation End
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CirclePanel extends StatelessWidget {
  const _CirclePanel({
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
          // Safety Circle Panel Header Start
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
          // Safety Circle Panel Header End
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ContactListItem extends StatelessWidget {
  const _ContactListItem({
    required this.name,
    required this.detail,
    required this.relation,
    this.showActions = false,
  });

  final String name;
  final String detail;
  final String relation;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F7EE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF3C8B68),
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      detail,
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                relation,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF3C8B68),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SecondaryCircleButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SecondaryCircleButton(
                    icon: Icons.swap_vert_rounded,
                    label: 'Priority',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DangerCircleButton(label: 'Remove', onTap: () {}),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleTextField extends StatelessWidget {
  const _CircleTextField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 1,
      cursorColor: TutelaColors.plum,
      style: GoogleFonts.dmSans(
        color: TutelaColors.plum,
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
        fillColor: TutelaColors.ivory.withValues(alpha: 0.2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
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

class _PriorityButton extends StatelessWidget {
  const _PriorityButton({
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
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? TutelaColors.plum : TutelaColors.canvas,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: TutelaColors.plum, width: 1.2),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: selected ? TutelaColors.canvas : TutelaColors.plum,
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

class _PrimaryCircleButton extends StatelessWidget {
  const _PrimaryCircleButton({required this.label, required this.onTap});

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

class _SecondaryCircleButton extends StatelessWidget {
  const _SecondaryCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
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
            Icon(icon, color: TutelaColors.plum, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerCircleButton extends StatelessWidget {
  const _DangerCircleButton({required this.label, required this.onTap});

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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: TutelaColors.plum,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

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
              color: TutelaColors.plum.withValues(alpha: 0.08),
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
