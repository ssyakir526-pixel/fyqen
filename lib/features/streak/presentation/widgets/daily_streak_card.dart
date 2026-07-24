import 'package:flutter/material.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak.dart';
import 'package:fyqen/features/streak/domain/entities/daily_streak_milestone.dart';
import 'package:fyqen/features/streak/presentation/state/daily_streak_view_state.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// A compact, presentation-only view of authenticated Daily Streak state.
final class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({super.key, required this.state, this.onRetry});

  final DailyStreakViewState state;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      DailyStreakStatus.initial ||
      DailyStreakStatus.loading => const _DailyStreakLoadingCard(),
      DailyStreakStatus.failure => _DailyStreakFailureCard(onRetry: onRetry),
      DailyStreakStatus.ready => _DailyStreakReadyCard(streak: state.streak!),
    };
  }
}

final class _DailyStreakLoadingCard extends StatelessWidget {
  const _DailyStreakLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Daily Streak information is loading.',
      child: AppCard(
        key: const Key('dashboard-daily-streak-card'),
        child: Text(
          'Daily Streak information is loading.',
          key: const Key('dashboard-daily-streak-loading'),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

final class _DailyStreakFailureCard extends StatelessWidget {
  const _DailyStreakFailureCard({this.onRetry});

  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Daily Streak information is temporarily unavailable.',
      child: AppCard(
        key: const Key('dashboard-daily-streak-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Streak information is temporarily unavailable.',
              key: const Key('dashboard-daily-streak-failure'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                key: const Key('dashboard-daily-streak-retry'),
                label: 'Retry',
                onPressed: onRetry,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _DailyStreakReadyCard extends StatelessWidget {
  const _DailyStreakReadyCard({required this.streak});

  final DailyStreak streak;

  @override
  Widget build(BuildContext context) {
    final DailyStreakMilestoneSummary milestone =
        DailyStreakMilestoneSummary.fromStreak(streak);
    final String current = _days(streak.currentStreak);
    final String longest = _days(streak.longestStreak);
    final DailyStreakMilestone? next = milestone.nextMilestone;
    final String nextLabel = next?.label ?? 'All milestones reached';
    final String progress = next == null
        ? 'All milestones reached'
        : '${streak.currentStreak} of ${next.requiredDays} days';

    return Semantics(
      container: true,
      label:
          'Daily Streak. Current streak $current. Longest streak $longest. Next milestone $nextLabel. $progress.',
      child: AppCard(
        key: const Key('dashboard-daily-streak-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Daily Streak',
              key: const Key('dashboard-daily-streak-heading'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Open Fyqen each day to continue your streak.',
              key: const Key('dashboard-daily-streak-supporting-text'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _Metric(
              label: 'Current streak',
              value: current,
              labelKey: const Key('dashboard-daily-streak-current-label'),
              valueKey: const Key('dashboard-daily-streak-current-value'),
            ),
            const SizedBox(height: AppSpacing.md),
            _Metric(
              label: 'Longest streak',
              value: longest,
              labelKey: const Key('dashboard-daily-streak-longest-label'),
              valueKey: const Key('dashboard-daily-streak-longest-value'),
            ),
            const SizedBox(height: AppSpacing.md),
            _Metric(
              label: 'Next milestone',
              value: nextLabel,
              labelKey: const Key(
                'dashboard-daily-streak-next-milestone-label',
              ),
              valueKey: const Key(
                'dashboard-daily-streak-next-milestone-value',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (next == null)
              Text(
                progress,
                key: const Key('dashboard-daily-streak-all-milestones'),
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...<Widget>[
              Text(
                progress,
                key: const Key('dashboard-daily-streak-progress-text'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                label: progress,
                child: LinearProgressIndicator(
                  key: const Key('dashboard-daily-streak-progress-indicator'),
                  value: milestone.progressRatio,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your streak updates once per calendar day.',
              key: const Key('dashboard-daily-streak-update-info'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

final class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.labelKey,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key labelKey;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          key: labelKey,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          key: valueKey,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

String _days(int value) => value == 1 ? '1 day' : '$value days';
