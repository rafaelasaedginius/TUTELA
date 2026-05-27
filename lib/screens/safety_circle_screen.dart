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
  String _linkedHelp = 'None';
  bool _checkInMode = true;

  bool get _usesCustomHelp => _linkedHelp == 'Custom';
  String get _assignedContact {
    switch (_priority) {
      case '1st':
        return 'Mama';
      case '2nd':
        return 'Nadia';
      case '3rd':
        return 'Campus Security';
      default:
        return '';
    }
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
                        // SOS Chain Summary Start
                        _SosChainPanel(onSendSos: () {}),
                        // SOS Chain Summary End
                        const SizedBox(height: 14),
                        // Contact List Section Start
                        _CirclePanel(
                          title: 'View contact list',
                          subtitle:
                              'Sorted by priority with last-pinged status.',
                          child: Column(
                            children: [
                              const _ContactListItem(
                                priority: '1st',
                                name: 'Mama',
                                detail: 'Family - pinged 4 min ago',
                                linkedHelp: 'None',
                                showActions: true,
                              ),
                              const SizedBox(height: 10),
                              const _ContactListItem(
                                priority: '2nd',
                                name: 'Nadia',
                                detail: 'Friend - pinged yesterday',
                                linkedHelp: 'Campus Security',
                                showActions: true,
                              ),
                              const SizedBox(height: 10),
                              const _ContactListItem(
                                priority: '3rd',
                                name: 'Campus Security',
                                detail: 'Local help point - helpline',
                                linkedHelp: 'Official help',
                                showActions: true,
                              ),
                            ],
                          ),
                        ),
                        // Contact List Section End
                        const SizedBox(height: 14),
                        // Add Contact Section Start
                        _CirclePanel(
                          title: 'Add contact',
                          subtitle: 'Each priority slot holds one SOS contact.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(height: 12),
                              _CircleTextField(
                                hint: 'Alert message template',
                                maxLines: 3,
                              ),
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
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: TutelaColors.peach.withValues(
                                    alpha: 0.14,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$_priority priority is currently assigned to $_assignedContact. Saving this contact as $_priority will replace $_assignedContact in the SOS chain.',
                                  style: GoogleFonts.dmSans(
                                    color: TutelaColors.plum.withValues(
                                      alpha: 0.72,
                                    ),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.25,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _SectionLabel('Linked local help'),
                              const SizedBox(height: 9),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _HelpChoiceChip(
                                    label: 'None',
                                    selected: _linkedHelp == 'None',
                                    onTap: () {
                                      setState(() {
                                        _linkedHelp = 'None';
                                      });
                                    },
                                  ),
                                  _HelpChoiceChip(
                                    label: 'Campus Security',
                                    selected: _linkedHelp == 'Campus Security',
                                    onTap: () {
                                      setState(() {
                                        _linkedHelp = 'Campus Security';
                                      });
                                    },
                                  ),
                                  _HelpChoiceChip(
                                    label: 'Police Station',
                                    selected: _linkedHelp == 'Police Station',
                                    onTap: () {
                                      setState(() {
                                        _linkedHelp = 'Police Station';
                                      });
                                    },
                                  ),
                                  _HelpChoiceChip(
                                    label: 'Women Helpline',
                                    selected: _linkedHelp == 'Women Helpline',
                                    onTap: () {
                                      setState(() {
                                        _linkedHelp = 'Women Helpline';
                                      });
                                    },
                                  ),
                                  _HelpChoiceChip(
                                    label: 'Custom',
                                    selected: _linkedHelp == 'Custom',
                                    onTap: () {
                                      setState(() {
                                        _linkedHelp = 'Custom';
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_usesCustomHelp) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _CircleTextField(
                                        hint: 'Help name',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _CircleTextField(
                                        hint: 'Help phone',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 14),
                              // Check-in Mode Start
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: TutelaColors.ivory.withValues(
                                    alpha: 0.22,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: TutelaColors.plum.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: TutelaColors.plum,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Check-in mode',
                                            style: GoogleFonts.dmSans(
                                              color: TutelaColors.plum,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              height: 1,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Sends safety updates, not only SOS alerts.',
                                            style: GoogleFonts.dmSans(
                                              color: TutelaColors.plum
                                                  .withValues(alpha: 0.58),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              height: 1.15,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _checkInMode,
                                      activeThumbColor: TutelaColors.plum,
                                      activeTrackColor: TutelaColors.rose
                                          .withValues(alpha: 0.28),
                                      onChanged: (value) {
                                        setState(() {
                                          _checkInMode = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              // Check-in Mode End
                              const SizedBox(height: 14),
                              _PrimaryCircleButton(
                                label: 'Save contact',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // Add Contact Section End
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

class _SosChainPanel extends StatelessWidget {
  const _SosChainPanel({required this.onSendSos});

  final VoidCallback onSendSos;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOS Chain Header Start
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: TutelaColors.canvas.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sos_rounded,
                  color: TutelaColors.canvas,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOS alert chain',
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.canvas,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Alerts are sent from 1st to 3rd priority.',
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.canvas.withValues(alpha: 0.8),
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
          ),
          // SOS Chain Header End
          const SizedBox(height: 16),
          const _ChainStep(
            priority: '1st',
            name: 'Mama',
            detail: 'Receives live location first',
          ),
          const SizedBox(height: 10),
          const _ChainStep(
            priority: '2nd',
            name: 'Nadia',
            detail: 'Receives linked campus security info',
          ),
          const SizedBox(height: 10),
          const _ChainStep(
            priority: '3rd',
            name: 'Campus Security',
            detail: 'Official local help point',
          ),
          const SizedBox(height: 16),
          _LightCircleButton(label: 'Send SOS alert chain', onTap: onSendSos),
        ],
      ),
    );
  }
}

class _ChainStep extends StatelessWidget {
  const _ChainStep({
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
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TutelaColors.canvas.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Text(
            priority,
            style: GoogleFonts.dmSans(
              color: TutelaColors.canvas,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0,
            ),
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
                  color: TutelaColors.canvas,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.canvas.withValues(alpha: 0.78),
                  fontSize: 12,
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
    required this.priority,
    required this.name,
    required this.detail,
    required this.linkedHelp,
    this.showActions = false,
  });

  final String priority;
  final String name;
  final String detail;
  final String linkedHelp;
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F7EE),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  priority,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF3C8B68),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: TutelaColors.canvas,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: TutelaColors.plum.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  linkedHelp,
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF3C8B68),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
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
  const _CircleTextField({required this.hint, this.maxLines = 1});

  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
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

class _HelpChoiceChip extends StatelessWidget {
  const _HelpChoiceChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? TutelaColors.plum : TutelaColors.canvas,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: TutelaColors.plum, width: 1.2),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: selected ? TutelaColors.canvas : TutelaColors.plum,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            height: 1,
            letterSpacing: 0,
          ),
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

class _LightCircleButton extends StatelessWidget {
  const _LightCircleButton({required this.label, required this.onTap});

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
          color: TutelaColors.canvas,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.plum,
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
