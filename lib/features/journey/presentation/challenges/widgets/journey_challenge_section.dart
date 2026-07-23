import 'package:flutter/material.dart';

import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/journey/presentation/challenges/models/challenge_catalog.dart';
import 'package:fyqen/shared/widgets/app_card.dart';

/// The derived Challenge content shown inside the Journey destination.
final class JourneyChallengeSection extends StatelessWidget {
  const JourneyChallengeSection({super.key, required this.summary});

  final ChallengeCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    final ChallengeSummary? recommended = summary.recommendedChallenge;

    return Column(
      key: const Key('journey-challenge-section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Current Challenge',
          key: const Key('journey-challenge-heading'),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'A measurable next step based on your current Portfolio.',
          key: const Key('journey-challenge-supporting-text'),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ChallengeOverviewCard(summary: summary),
        const SizedBox(height: AppSpacing.md),
        if (recommended == null)
          const _AllChallengesCompletedCard()
        else
          _RecommendedChallengeCard(challenge: recommended),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Challenge status updates when your Portfolio changes.',
          key: const Key('journey-challenge-update-info'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        _ChallengeList(summary: summary),
      ],
    );
  }
}

final class _ChallengeOverviewCard extends StatelessWidget {
  const _ChallengeOverviewCard({required this.summary});

  final ChallengeCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    final String completedLabel =
        '${summary.completedCount} of ${summary.totalCount} completed';
    final String progressLabel =
        '${summary.formattedOverallCompletion} complete';

    return Semantics(
      container: true,
      label: 'Challenge overview. $completedLabel. $progressLabel.',
      child: AppCard(
        key: const Key('journey-challenge-overview-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Challenge Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              completedLabel,
              key: const Key('journey-challenge-completed-count'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              progressLabel,
              key: const Key('journey-challenge-overall-progress'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              label: 'Overall Challenge completion $progressLabel',
              child: LinearProgressIndicator(
                key: const Key('journey-challenge-progress-indicator'),
                value: summary.overallCompletionRatio,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _RecommendedChallengeCard extends StatelessWidget {
  const _RecommendedChallengeCard({required this.challenge});

  final ChallengeSummary challenge;

  @override
  Widget build(BuildContext context) {
    final String statusLabel = _statusLabel(challenge.status);
    final String detail = challenge.status == ChallengeStatus.unavailable
        ? challenge.evaluation.unavailableReason ?? 'Challenge is unavailable.'
        : challenge.evaluation.formattedProgress ?? '';
    final String semanticsLabel =
        '${challenge.definition.title}. $statusLabel. $detail';

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: AppCard(
        key: const Key('journey-current-challenge-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              challenge.definition.title,
              key: const Key('journey-current-challenge-title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              challenge.definition.description,
              key: const Key('journey-current-challenge-description'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              challenge.definition.category.label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              statusLabel,
              key: const Key('journey-current-challenge-status'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (challenge.status == ChallengeStatus.unavailable)
              _UnavailableReason(
                key: const Key('journey-current-challenge-unavailable-reason'),
                reason: detail,
              )
            else
              _Progress(
                key: const Key('journey-current-challenge-progress'),
                progress: detail,
                ratio: challenge.evaluation.progressRatio,
              ),
          ],
        ),
      ),
    );
  }
}

final class _AllChallengesCompletedCard extends StatelessWidget {
  const _AllChallengesCompletedCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'All Challenges Completed. Eight of eight completed.',
      child: AppCard(
        key: const Key('journey-all-challenges-completed'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'All Challenges Completed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your current Portfolio satisfies every available Challenge.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

final class _ChallengeList extends StatelessWidget {
  const _ChallengeList({required this.summary});

  final ChallengeCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('journey-challenge-list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('All Challenges', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        for (final ChallengeSummary challenge
            in summary.challenges) ...<Widget>[
          _ChallengeCard(challenge: challenge),
          if (challenge != summary.challenges.last)
            const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

final class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final ChallengeSummary challenge;

  @override
  Widget build(BuildContext context) {
    final String id = challenge.definition.id;
    final String statusLabel = _statusLabel(challenge.status);
    final String detail = challenge.status == ChallengeStatus.unavailable
        ? challenge.evaluation.unavailableReason ?? 'Challenge is unavailable.'
        : challenge.evaluation.formattedProgress ?? '';

    return Semantics(
      container: true,
      label: '${challenge.definition.title}. $statusLabel. $detail',
      child: AppCard(
        key: Key('challenge-$id'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              challenge.definition.title,
              key: Key('challenge-$id-title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              challenge.definition.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${challenge.definition.category.label} - $statusLabel',
              key: Key('challenge-$id-status'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (challenge.status == ChallengeStatus.unavailable)
              _UnavailableReason(
                key: Key('challenge-$id-unavailable-reason'),
                reason: detail,
              )
            else
              _Progress(
                key: Key('challenge-$id-progress'),
                progress: detail,
                ratio: challenge.evaluation.progressRatio,
              ),
          ],
        ),
      ),
    );
  }
}

final class _Progress extends StatelessWidget {
  const _Progress({super.key, required this.progress, required this.ratio});

  final String progress;
  final double? ratio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: AppSpacing.sm),
        Text(progress, style: Theme.of(context).textTheme.bodyMedium),
        if (ratio != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            label: progress,
            child: LinearProgressIndicator(value: ratio),
          ),
        ],
      ],
    );
  }
}

final class _UnavailableReason extends StatelessWidget {
  const _UnavailableReason({super.key, required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(reason, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

String _statusLabel(ChallengeStatus status) => switch (status) {
  ChallengeStatus.active => 'Active',
  ChallengeStatus.completed => 'Completed',
  ChallengeStatus.unavailable => 'Unavailable',
};
