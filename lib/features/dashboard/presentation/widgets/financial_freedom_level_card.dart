import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/dashboard/presentation/models/financial_freedom_level_summary.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// Compact Dashboard presentation for a derived Financial Freedom level.
final class FinancialFreedomLevelCard extends StatelessWidget {
  const FinancialFreedomLevelCard({required this.summary, super.key});

  final FinancialFreedomLevelSummary summary;

  @override
  Widget build(BuildContext context) {
    final int? currentLevel = summary.currentLevel;
    final String? progressLabel = summary.progressToNextLevelLabel;
    if (!summary.isAvailable || currentLevel == null || progressLabel == null) {
      return _UnavailableLevelCard(reason: summary.unavailableReason);
    }

    final bool isMaximumLevel = summary.isMaximumLevel;

    return Semantics(
      container: true,
      label: 'Level $currentLevel. $progressLabel',
      child: AppCard(
        key: const Key('financial-freedom-level-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Level $currentLevel',
              key: const Key('financial-freedom-current-level'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (isMaximumLevel)
              Text(
                'Maximum level reached',
                key: const Key('financial-freedom-maximum-level-message'),
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...<Widget>[
              Text(
                progressLabel,
                key: const Key('financial-freedom-level-progress-percentage'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              LinearProgressIndicator(
                key: const Key('financial-freedom-level-progress-indicator'),
                value: summary.progressToNextLevelRatio,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (summary.nextLevel case final int nextLevel)
                Text(
                  'Level $nextLevel',
                  key: const Key('financial-freedom-next-level'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
            if (isMaximumLevel) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              const LinearProgressIndicator(
                key: Key('financial-freedom-level-progress-indicator'),
                value: 1,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _UnavailableLevelCard extends StatelessWidget {
  const _UnavailableLevelCard({this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    final String message =
        reason ?? 'Your level cannot be calculated right now.';

    return Semantics(
      container: true,
      label: 'Level unavailable. $message',
      child: AppCard(
        key: const Key('financial-freedom-level-unavailable'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Level unavailable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
