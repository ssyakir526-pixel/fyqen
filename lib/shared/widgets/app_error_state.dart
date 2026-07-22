import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'app_button.dart';

/// A controlled, user-facing error presentation with optional retry intent.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    required this.title,
    required this.message,
    super.key,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Icon(
                Icons.error_outline,
                color: colorScheme.onErrorContainer,
                size: AppSpacing.xl,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry case final VoidCallback onRetry) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: retryLabel, onPressed: onRetry, expand: false),
          ],
        ],
      ),
    );
  }
}
