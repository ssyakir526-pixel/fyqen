import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Adds consistent separation after a major page section.
class AppSection extends StatelessWidget {
  const AppSection({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: child,
    );
  }
}
