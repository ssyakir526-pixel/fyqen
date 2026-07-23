import 'package:flutter/material.dart';

import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/achievements/presentation/models/achievement_catalog.dart';
import 'package:fyqen/features/achievements/presentation/models/achievement_evaluation_context.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/shared/widgets/app_card.dart';
import 'package:fyqen/shared/widgets/app_page.dart';
import 'package:fyqen/shared/widgets/app_section.dart';
import 'package:fyqen/shared/widgets/section_title.dart';

/// Derived, revocable Achievement catalog for the shared Portfolio snapshot.
final class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key, this.portfolio});

  final Portfolio? portfolio;

  @override
  Widget build(BuildContext context) {
    final Portfolio? currentPortfolio = portfolio;
    final AchievementEvaluationContext context = currentPortfolio == null
        ? const AchievementEvaluationContext.empty()
        : AchievementEvaluationContext.fromPortfolio(currentPortfolio);
    final AchievementCatalogSummary summary =
        AchievementCatalogSummary.fromContext(context);

    return Scaffold(
      key: const Key('achievements-page'),
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: AppPage(
        children: <Widget>[
          const AppSection(
            child: SectionTitle(
              title: 'Achievements',
              subtitle: 'Milestones based on your current financial progress.',
            ),
          ),
          AppSection(child: _OverviewCard(summary: summary)),
          const AppSection(child: _RevocableInfo()),
          _AchievementSections(summary: summary),
        ],
      ),
    );
  }
}

final class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.summary});

  final AchievementCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          '${summary.earnedCount} of ${summary.totalCount} Achievements earned. ${summary.formattedOverallCompletion} complete.',
      child: AppCard(
        key: const Key('achievements-overview-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Overview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${summary.earnedCount} of ${summary.totalCount} earned',
              key: const Key('achievements-earned-count'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${summary.formattedOverallCompletion} complete',
              key: const Key('achievements-overall-progress'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              label:
                  'Achievement completion ${summary.formattedOverallCompletion}',
              child: LinearProgressIndicator(
                key: const Key('achievements-overall-progress-indicator'),
                value: summary.overallCompletionRatio,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Achievements update when your financial position changes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

final class _RevocableInfo extends StatelessWidget {
  const _RevocableInfo();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: const Key('achievements-revocable-info'),
      child: Text(
        'Achievement status reflects your current Portfolio and may change when your financial position changes.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

final class _AchievementSections extends StatelessWidget {
  const _AchievementSections({required this.summary});

  final AchievementCatalogSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('achievements-list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final AchievementCategory category in AchievementCategory.values)
          _AchievementCategorySection(
            category: category,
            achievements: summary.achievements
                .where(
                  (AchievementSummary item) =>
                      item.definition.category == category,
                )
                .toList(growable: false),
          ),
      ],
    );
  }
}

final class _AchievementCategorySection extends StatelessWidget {
  const _AchievementCategorySection({
    required this.category,
    required this.achievements,
  });

  final AchievementCategory category;
  final List<AchievementSummary> achievements;

  @override
  Widget build(BuildContext context) {
    final String keyName = switch (category) {
      AchievementCategory.portfolio => 'achievements-portfolio-section',
      AchievementCategory.progress => 'achievements-progress-section',
      AchievementCategory.journey => 'achievements-journey-section',
      AchievementCategory.financialFreedom =>
        'achievements-financial-freedom-section',
    };

    return AppSection(
      child: Column(
        key: Key(keyName),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionTitle(title: category.label),
          for (final AchievementSummary achievement
              in achievements) ...<Widget>[
            _AchievementCard(summary: achievement),
            if (achievement != achievements.last)
              const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

final class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.summary});

  final AchievementSummary summary;

  @override
  Widget build(BuildContext context) {
    final AchievementDefinition definition = summary.definition;
    final String statusLabel = switch (summary.status) {
      AchievementStatus.earned => 'Earned',
      AchievementStatus.unearned => 'Not earned',
      AchievementStatus.unavailable => 'Unavailable',
    };
    final String? progress = summary.evaluation.formattedProgress;
    final String? unavailableReason = summary.evaluation.unavailableReason;
    final Color statusColor = summary.status == AchievementStatus.earned
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return Semantics(
      container: true,
      label:
          '${definition.title}. $statusLabel.${progress == null ? '' : ' $progress.'}${unavailableReason == null ? '' : ' $unavailableReason'}',
      child: AppCard(
        key: Key('achievement-${definition.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              definition.title,
              key: Key('achievement-${definition.id}-title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              definition.description,
              key: Key('achievement-${definition.id}-description'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              definition.category.label,
              key: Key('achievement-${definition.id}-category'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              statusLabel,
              key: Key('achievement-${definition.id}-status'),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: statusColor),
            ),
            if (progress != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                progress,
                key: Key('achievement-${definition.id}-progress'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (unavailableReason != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                unavailableReason,
                key: Key('achievement-${definition.id}-unavailable-reason'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
