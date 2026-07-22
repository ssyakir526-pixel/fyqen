import 'package:flutter/material.dart';

/// A presentation-only definition for a Dashboard quick action.
class DashboardQuickAction {
  const DashboardQuickAction({
    required this.label,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
}
