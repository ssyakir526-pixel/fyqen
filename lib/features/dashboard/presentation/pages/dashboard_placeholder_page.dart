import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../features/portfolio/domain/entities/portfolio.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/section_title.dart';
import '../models/dashboard_portfolio_summary.dart';
import '../widgets/dashboard_quick_action.dart';
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
  });

  final Portfolio? portfolio;
  final bool isPortfolioSaving;

  @override
  Widget build(BuildContext context) {
    final Portfolio? currentPortfolio = portfolio;
    final DashboardPortfolioSummary? summary = currentPortfolio == null
        ? null
        : DashboardPortfolioSummary.fromPortfolio(currentPortfolio);

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
                const FinancialIndependenceProgressCard(hasData: false),
              ],
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
}
