import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A centered progress indicator with optional supporting context.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Loading',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(color: colorScheme.primary),
            if (message case final String message) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
