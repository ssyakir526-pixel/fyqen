import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A themed content card with Fyqen's standard internal spacing.
class AppCard extends StatelessWidget {
  const AppCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: child,
      ),
    );
  }
}
