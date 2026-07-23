import 'package:flutter/material.dart';

import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_spacing.dart';
import 'package:fyqen/features/dashboard/presentation/models/dashboard_portfolio_summary.dart';
import 'package:fyqen/features/dashboard/presentation/models/financial_freedom_level_summary.dart';
import 'package:fyqen/features/journey/presentation/challenges/models/challenge_catalog.dart';
import 'package:fyqen/features/journey/presentation/challenges/models/challenge_evaluation_context.dart';
import 'package:fyqen/features/journey/presentation/challenges/widgets/journey_challenge_section.dart';
import 'package:fyqen/features/journey/presentation/models/financial_freedom_journey_summary.dart';
import 'package:fyqen/features/journey/presentation/models/journey_stage_summary.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';
import 'package:fyqen/features/portfolio/presentation/widgets/financial_independence_target_form.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/app_card.dart';
import 'package:fyqen/shared/widgets/app_page.dart';
import 'package:fyqen/shared/widgets/app_section.dart';
import 'package:fyqen/shared/widgets/section_title.dart';

/// The existing Journey destination, derived from the shared Portfolio snapshot.
final class JourneyPlaceholderPage extends StatelessWidget {
  const JourneyPlaceholderPage({
    super.key,
    this.portfolio,
    this.isPortfolioSaving = false,
    this.onSetFinancialIndependenceTarget,
  });

  final Portfolio? portfolio;
  final bool isPortfolioSaving;
  final Future<bool> Function(FinancialIndependenceTarget target)?
  onSetFinancialIndependenceTarget;

  @override
  Widget build(BuildContext context) {
    final Portfolio? currentPortfolio = portfolio;
    final DashboardPortfolioSummary? dashboardSummary = currentPortfolio == null
        ? null
        : DashboardPortfolioSummary.fromPortfolio(currentPortfolio);
    final FinancialFreedomLevelSummary? levelSummary = dashboardSummary == null
        ? null
        : FinancialFreedomLevelSummary.fromDashboardSummary(dashboardSummary);
    final FinancialFreedomJourneySummary summary = dashboardSummary == null
        ? const FinancialFreedomJourneySummary.noTarget()
        : FinancialFreedomJourneySummary.fromSummaries(
            dashboardSummary: dashboardSummary,
            levelSummary: levelSummary!,
          );
    final ChallengeEvaluationContext challengeContext = currentPortfolio == null
        ? const ChallengeEvaluationContext.empty()
        : ChallengeEvaluationContext.fromSummaries(
            portfolio: currentPortfolio,
            dashboardSummary: dashboardSummary!,
            levelSummary: levelSummary!,
            journeySummary: summary,
          );
    final ChallengeCatalogSummary challengeSummary =
        ChallengeCatalogSummary.fromContext(challengeContext);

    return Scaffold(
      key: const Key('journey-page'),
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: AppPage(
        children: <Widget>[
          const AppSection(
            child: SectionTitle(
              title: 'Journey',
              subtitle: 'Your path toward financial freedom.',
            ),
          ),
          if (!summary.isAvailable)
            AppSection(
              child: summary.isNoTarget
                  ? _NoTargetJourneyCard(
                      portfolio: currentPortfolio,
                      isSaving: isPortfolioSaving,
                      onSetTarget: onSetFinancialIndependenceTarget,
                    )
                  : _UnavailableJourneyCard(reason: summary.unavailableReason),
            )
          else ...<Widget>[
            AppSection(child: _CurrentPositionCard(summary: summary)),
            AppSection(
              child: summary.isComplete
                  ? const _CompletedJourneyCard()
                  : _NextDirectionCard(summary: summary),
            ),
          ],
          AppSection(child: JourneyChallengeSection(summary: challengeSummary)),
          if (summary.isAvailable)
            AppSection(child: _JourneyTimeline(summary: summary)),
        ],
      ),
    );
  }
}

final class _NoTargetJourneyCard extends StatelessWidget {
  const _NoTargetJourneyCard({
    required this.portfolio,
    required this.isSaving,
    required this.onSetTarget,
  });

  final Portfolio? portfolio;
  final bool isSaving;
  final Future<bool> Function(FinancialIndependenceTarget target)? onSetTarget;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Set your FI target. Add your Financial Independence target to begin tracking your Journey.',
      child: AppCard(
        key: const Key('journey-no-target-state'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Set your FI target',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your Financial Independence target to begin tracking your Journey.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              key: const Key('journey-set-fi-target-button'),
              label: 'Set FI Target',
              onPressed: onSetTarget == null || isSaving
                  ? null
                  : () => _openTargetForm(context),
              expand: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTargetForm(BuildContext context) async {
    final Future<bool> Function(FinancialIndependenceTarget target)? onSubmit =
        onSetTarget;
    if (onSubmit == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FinancialIndependenceTargetForm(
          initialTarget: portfolio?.financialIndependenceTarget,
          onSubmit: onSubmit,
          isSaving: isSaving,
        );
      },
    );
  }
}

final class _UnavailableJourneyCard extends StatelessWidget {
  const _UnavailableJourneyCard({this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    final String message =
        reason ??
        'Your Journey cannot be calculated while your financial values use different currencies.';

    return Semantics(
      container: true,
      label: 'Journey unavailable. $message',
      child: AppCard(
        key: const Key('journey-unavailable-state'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Journey unavailable',
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

final class _CurrentPositionCard extends StatelessWidget {
  const _CurrentPositionCard({required this.summary});

  final FinancialFreedomJourneySummary summary;

  @override
  Widget build(BuildContext context) {
    final int? currentLevel = summary.currentLevel;
    final JourneyStageSummary? currentStage = summary.currentStage;
    if (currentLevel == null) {
      return const SizedBox.shrink();
    }

    final String positionLabel = currentStage?.name ?? 'Journey complete';
    final String overallProgress = summary.formattedOverallProgress ?? '0%';
    final int? nextCheckpoint = summary.nextCheckpointLevel;

    return Semantics(
      container: true,
      label:
          'Current position. Level $currentLevel. $positionLabel. $overallProgress of FI target.',
      child: AppCard(
        key: const Key('journey-current-position-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Current Position',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Level $currentLevel',
              key: const Key('journey-current-level'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (currentStage == null)
              Text(
                positionLabel,
                style: Theme.of(context).textTheme.titleMedium,
              )
            else
              Text(
                positionLabel,
                key: const Key('journey-current-stage'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '$overallProgress of FI target',
              key: const Key('journey-overall-progress-percentage'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              label: 'Overall FI progress $overallProgress',
              child: LinearProgressIndicator(
                key: const Key('journey-overall-progress-indicator'),
                value: summary.overallProgressRatio,
              ),
            ),
            if (nextCheckpoint case final int checkpoint) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Next checkpoint: Level $checkpoint',
                key: const Key('journey-next-checkpoint'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _JourneyTimeline extends StatelessWidget {
  const _JourneyTimeline({required this.summary});

  final FinancialFreedomJourneySummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('journey-stage-timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SectionTitle(title: 'Journey Stages'),
        for (final JourneyStageSummary stage in summary.stages) ...<Widget>[
          _JourneyStageCard(stage: stage),
          if (stage.stageNumber != summary.stages.last.stageNumber)
            const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

final class _JourneyStageCard extends StatelessWidget {
  const _JourneyStageCard({required this.stage});

  final JourneyStageSummary stage;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String statusLabel = switch (stage.status) {
      JourneyStageStatus.completed => 'Completed',
      JourneyStageStatus.current => 'Current',
      JourneyStageStatus.upcoming => 'Upcoming',
    };
    final IconData statusIcon = switch (stage.status) {
      JourneyStageStatus.completed => Icons.check_circle_outline,
      JourneyStageStatus.current => Icons.adjust,
      JourneyStageStatus.upcoming => Icons.radio_button_unchecked,
    };
    final Color statusColor = stage.status == JourneyStageStatus.current
        ? colorScheme.primary
        : colorScheme.onSurface;

    return Semantics(
      container: true,
      label:
          'Stage ${stage.stageNumber}. ${stage.name}. Level ${stage.checkpointLevel}. $statusLabel.',
      child: AppCard(
        key: Key('journey-stage-${stage.stageNumber}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(statusIcon, color: statusColor),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Stage ${stage.stageNumber}',
                    style: textTheme.labelLarge,
                  ),
                ),
                Text(
                  statusLabel,
                  key: Key('journey-stage-${stage.stageNumber}-status'),
                  style: textTheme.labelLarge?.copyWith(color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              stage.name,
              key: Key('journey-stage-${stage.stageNumber}-name'),
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(stage.description, style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Checkpoint: Level ${stage.checkpointLevel}',
              key: Key('journey-stage-${stage.stageNumber}-checkpoint'),
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

final class _NextDirectionCard extends StatelessWidget {
  const _NextDirectionCard({required this.summary});

  final FinancialFreedomJourneySummary summary;

  @override
  Widget build(BuildContext context) {
    final JourneyStageSummary? stage = summary.currentStage;
    final int? checkpoint = summary.nextCheckpointLevel;
    final int? levelsRemaining = summary.levelsRemainingToNextCheckpoint;
    if (stage == null || checkpoint == null || levelsRemaining == null) {
      return const SizedBox.shrink();
    }

    final String progressLabel = summary.nextLevelProgressLabel ?? '';

    return Semantics(
      container: true,
      label:
          'Next direction. Reach Level $checkpoint to complete ${stage.name}. $levelsRemaining levels remain. $progressLabel',
      child: AppCard(
        key: const Key('journey-next-direction-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Next Direction',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Reach Level $checkpoint to complete the ${stage.name} stage.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$levelsRemaining levels remain until Level $checkpoint.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (progressLabel.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Text(
                progressLabel,
                key: const Key('journey-next-level-progress'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _CompletedJourneyCard extends StatelessWidget {
  const _CompletedJourneyCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label:
          'Financial Freedom reached. You have reached your configured Financial Independence target.',
      child: AppCard(
        key: const Key('journey-complete-card'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Financial Freedom reached',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'You have reached your configured Financial Independence target.',
              key: const Key('journey-complete-message'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
