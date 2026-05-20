import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    // Button Start
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
    // Button End
  }
}
