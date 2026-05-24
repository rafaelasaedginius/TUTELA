import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';

class SupportGroupsScreen extends StatefulWidget {
  const SupportGroupsScreen({super.key});

  @override
  State<SupportGroupsScreen> createState() => _SupportGroupsScreenState();
}

class _SupportGroupsScreenState extends State<SupportGroupsScreen> {
  String _privacy = 'Public';
  String _filter = 'Nearby';

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
                // Support Groups Header Start
                Row(
                  children: [
                    _SupportIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAFF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Color(0xFF7660C8),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Support groups',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Community layer',
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
                // Support Groups Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Start Group Section Start
                        _SupportPanel(
                          title: 'Start a group',
                          subtitle:
                              'Create a named support group with privacy and description.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SupportTextField(hint: 'Group name'),
                              const SizedBox(height: 12),
                              _SupportTextField(
                                hint: 'Example: Night shift workers - Surabaya',
                              ),
                              const SizedBox(height: 14),
                              _SectionLabel('Privacy mode'),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SupportChoiceButton(
                                      label: 'Public',
                                      selected: _privacy == 'Public',
                                      onTap: () {
                                        setState(() {
                                          _privacy = 'Public';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _SupportChoiceButton(
                                      label: 'Invite-only',
                                      selected: _privacy == 'Invite-only',
                                      onTap: () {
                                        setState(() {
                                          _privacy = 'Invite-only';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _SupportTextField(
                                hint: 'Group description',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 14),
                              _PrimarySupportButton(
                                label: 'Create group',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        // Start Group Section End
                        const SizedBox(height: 14),
                        // Browse Groups Section Start
                        _SupportPanel(
                          title: 'Browse groups',
                          subtitle:
                              'Discover local groups by location tag or keyword.',
                          child: Column(
                            children: [
                              _SupportTextField(
                                hint: 'Search location or keyword',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SupportFilterChip(
                                      label: 'Nearby',
                                      selected: _filter == 'Nearby',
                                      onTap: () {
                                        setState(() {
                                          _filter = 'Nearby';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SupportFilterChip(
                                      label: 'Active',
                                      selected: _filter == 'Active',
                                      onTap: () {
                                        setState(() {
                                          _filter = 'Active';
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _SupportFilterChip(
                                      label: 'Pinned',
                                      selected: _filter == 'Pinned',
                                      onTap: () {
                                        setState(() {
                                          _filter = 'Pinned';
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const _SupportGroupItem(
                                name: 'Night shift workers',
                                detail: '128 members - active 12 min ago',
                                tag: 'Pinned',
                                showActions: true,
                              ),
                              const SizedBox(height: 10),
                              const _SupportGroupItem(
                                name: 'Campus walk home',
                                detail: '86 members - nearby group',
                                tag: 'Local',
                                showActions: true,
                              ),
                            ],
                          ),
                        ),
                        // Browse Groups Section End
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Bottom Navigation Start
                const TutelaBottomNav(selected: TutelaNavTab.support),
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

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({
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
          // Support Group Panel Header Start
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
          // Support Group Panel Header End
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SupportGroupItem extends StatelessWidget {
  const _SupportGroupItem({
    required this.name,
    required this.detail,
    required this.tag,
    this.showActions = false,
  });

  final String name;
  final String detail;
  final String tag;
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF0EAFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF7660C8),
                  size: 20,
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
                tag,
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF7660C8),
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
                  child: _SecondarySupportButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SecondarySupportButton(
                    icon: Icons.archive_outlined,
                    label: 'Archive',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DangerSupportButton(label: 'Delete', onTap: () {}),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SupportTextField extends StatelessWidget {
  const _SupportTextField({required this.hint, this.maxLines = 1});

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

class _SupportChoiceButton extends StatelessWidget {
  const _SupportChoiceButton({
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

class _SupportFilterChip extends StatelessWidget {
  const _SupportFilterChip({
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
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0EAFF)
              : TutelaColors.ivory.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF7660C8)
                : TutelaColors.plum.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.plum,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _PrimarySupportButton extends StatelessWidget {
  const _PrimarySupportButton({required this.label, required this.onTap});

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

class _SecondarySupportButton extends StatelessWidget {
  const _SecondarySupportButton({
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

class _DangerSupportButton extends StatelessWidget {
  const _DangerSupportButton({required this.label, required this.onTap});

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

class _SupportIconButton extends StatelessWidget {
  const _SupportIconButton({required this.icon, required this.onTap});

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
