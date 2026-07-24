import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../features/portfolio/domain/entities/portfolio.dart';
import '../../../../features/portfolio/domain/value_objects/financial_independence_target.dart';
import '../../../../features/portfolio/presentation/widgets/financial_independence_target_form.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../streak/presentation/state/daily_streak_view_state.dart';
import '../../../streak/presentation/widgets/daily_streak_card.dart';
import '../models/dashboard_portfolio_summary.dart';
import '../models/financial_freedom_level_summary.dart';
import '../widgets/dashboard_quick_action.dart';
import '../widgets/financial_freedom_level_card.dart';
import '../widgets/financial_independence_progress_card.dart';
import '../widgets/journey_overview_card.dart';
import '../widgets/net_worth_hero_card.dart';
import '../widgets/quick_actions_card.dart';

/// A presentation-only foundation for Fyqen's future Dashboard feature.
class DashboardPlaceholderPage extends StatelessWidget {
  const DashboardPlaceholderPage({
    super.key,
    this.portfolio,
    this.isPortfolioSaving = false,
    this.onSetFinancialIndependenceTarget,
    this.dailyStreakState = const DailyStreakViewState.loading(),
    this.onRetryDailyStreak,
  });

  final Portfolio? portfolio;
  final bool isPortfolioSaving;
  final Future<bool> Function(FinancialIndependenceTarget target)?
  onSetFinancialIndependenceTarget;
  final DailyStreakViewState dailyStreakState;
  final Future<void> Function()? onRetryDailyStreak;

  @override
  Widget build(BuildContext context) {
    final Portfolio? currentPortfolio = portfolio;
    final DashboardPortfolioSummary? summary = currentPortfolio == null
        ? null
        : DashboardPortfolioSummary.fromPortfolio(currentPortfolio);
    final FinancialFreedomLevelSummary? levelSummary = summary == null
        ? null
        : FinancialFreedomLevelSummary.fromDashboardSummary(summary);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: AppPage(
        children: <Widget>[
          AppSection(
            child: SectionTitle(
              title: currentPortfolio == null
                  ? 'Welcome back'
                  : 'Welcome back, ${currentPortfolio.name}',
              subtitle: isPortfolioSaving
                  ? 'Saving your portfolio...'
                  : 'Track your journey to financial freedom.',
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionTitle(title: 'Net Worth'),
                NetWorthHeroCard(
                  hasData: summary != null,
                  netWorthLabel: summary?.netWorthLabel,
                  subtitle: summary == null
                      ? null
                      : 'Assets: ${summary.totalAssetsLabel} • '
                            'Liabilities: ${summary.totalLiabilitiesLabel} • '
                            '${summary.assetCount} assets • '
                            '${summary.liabilityCount} liabilities',
                ),
              ],
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionTitle(title: 'Financial Independence'),
                if (summary == null || !summary.hasFinancialIndependenceTarget)
                  _FinancialIndependenceNoTargetCard(
                    onSetTarget: onSetFinancialIndependenceTarget,
                    isSaving: isPortfolioSaving,
                  )
                else ...<Widget>[
                  FinancialIndependenceProgressCard(
                    key: const Key('financial-independence-progress-card'),
                    hasData: summary.isFinancialIndependenceProgressAvailable,
                    progress: summary.financialIndependenceProgress,
                    progressLabel: summary.financialIndependenceProgressLabel,
                    currentValueLabel: summary.netWorthLabel,
                    targetValueLabel: summary.financialIndependenceTargetLabel,
                    subtitle: summary.isFinancialIndependenceProgressAvailable
                        ? null
                        : 'Progress cannot be calculated across currencies.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    key: const Key('edit-financial-independence-target-button'),
                    label: 'Edit Target',
                    onPressed: isPortfolioSaving
                        ? null
                        : () => _openTargetForm(context, currentPortfolio),
                    expand: false,
                  ),
                ],
              ],
            ),
          ),
          if (levelSummary != null &&
              summary?.hasFinancialIndependenceTarget == true)
            AppSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SectionTitle(title: 'Financial Freedom Level'),
                  FinancialFreedomLevelCard(summary: levelSummary),
                ],
              ),
            ),
          AppSection(
            child: DailyStreakCard(
              state: dailyStreakState,
              onRetry: onRetryDailyStreak,
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionTitle(title: 'Journey'),
                const JourneyOverviewCard(hasData: false),
              ],
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SectionTitle(title: 'Quick Actions'),
                const QuickActionsCard(
                  actions: <DashboardQuickAction>[
                    DashboardQuickAction(
                      label: 'Add asset',
                      icon: Icons.add_chart,
                    ),
                    DashboardQuickAction(
                      label: 'Add liability',
                      icon: Icons.remove_circle_outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTargetForm(
    BuildContext context,
    Portfolio? portfolio,
  ) async {
    final Future<bool> Function(FinancialIndependenceTarget target)? onSubmit =
        onSetFinancialIndependenceTarget;
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
          isSaving: isPortfolioSaving,
        );
      },
    );
  }
}

final class _FinancialIndependenceNoTargetCard extends StatelessWidget {
  const _FinancialIndependenceNoTargetCard({
    required this.onSetTarget,
    required this.isSaving,
  });

  final Future<bool> Function(FinancialIndependenceTarget target)? onSetTarget;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: const Key('financial-independence-no-target-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Set your FI target',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add the net worth goal you want to reach so Fyqen can calculate your financial freedom progress.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            key: const Key('set-financial-independence-target-button'),
            label: 'Set FI Target',
            onPressed: onSetTarget == null || isSaving
                ? null
                : () => _openForm(context),
            expand: false,
          ),
        ],
      ),
    );
  }

  Future<void> _openForm(BuildContext context) async {
    final Future<bool> Function(FinancialIndependenceTarget target)? onSubmit =
        onSetTarget;
    if (onSubmit == null) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FinancialIndependenceTargetForm(onSubmit: onSubmit);
      },
    );
  }
}
