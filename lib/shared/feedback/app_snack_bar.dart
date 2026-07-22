import 'package:flutter/material.dart';

import '../../core/theme/app_durations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

enum AppSnackBarType { success, error, info }

/// Displays concise, supplied user feedback through the active ScaffoldMessenger.
abstract final class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final _SnackBarVisual visual = switch (type) {
      AppSnackBarType.success => _SnackBarVisual(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        icon: Icons.check_circle_outline,
      ),
      AppSnackBarType.error => _SnackBarVisual(
        backgroundColor: colorScheme.errorContainer,
        foregroundColor: colorScheme.onErrorContainer,
        icon: Icons.error_outline,
      ),
      AppSnackBarType.info => _SnackBarVisual(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        icon: Icons.info_outline,
      ),
    };
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: AppDurations.snackBar,
        margin: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: visual.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        content: Row(
          children: <Widget>[
            Icon(visual.icon, color: visual.foregroundColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: visual.foregroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _SnackBarVisual {
  const _SnackBarVisual({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
}
