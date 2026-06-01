import 'package:flutter/material.dart';

enum IncidentCategory {
  harassment('Harassment', Icons.report_problem_outlined, Color(0xFFB23A48)),
  stalking('Stalking', Icons.visibility_outlined, Color(0xFF7A3B69)),
  poorLighting('Poor lighting', Icons.lightbulb_outline, Color(0xFFB58A3C)),
  unsafeTransport('Unsafe transport', Icons.directions_bus_outlined, Color(0xFF3B6AA0)),
  assault('Assault', Icons.warning_amber_rounded, Color(0xFF8B1E2D)),
  other('Other', Icons.more_horiz_rounded, Color(0xFF5A5A5A));

  const IncidentCategory(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum Severity {
  low('Low', 1, Color(0xFF6FAE6F)),
  medium('Medium', 2, Color(0xFFD9A441)),
  high('High', 3, Color(0xFFD96A3A)),
  critical('Critical', 4, Color(0xFFB23A48));

  const Severity(this.label, this.weight, this.color);
  final String label;
  final int weight;
  final Color color;

  bool get isUrgent => weight >= 3;
}

enum IncidentStatus { active, resolved, flagged, archived }