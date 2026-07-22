import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/section_title.dart';
import '../widgets/dashboard_quick_action.dart';
import '../widgets/financial_independence_progress_card.dart';
import '../widgets/journey_overview_card.dart';
import '../widgets/net_worth_hero_card.dart';
import '../widgets/quick_actions_card.dart';

/// A presentation-only foundation for Fyqen's future Dashboard feature.
class DashboardPlaceholderPage extends StatelessWidget {
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: AppPage(
        children: const <Widget>[
          AppSection(
            child: SectionTitle(
              title: 'Welcome back',
              subtitle: 'Track your journey to financial freedom.',
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionTitle(title: 'Net Worth'),
                NetWorthHeroCard(hasData: false),
              ],
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionTitle(title: 'Financial Independence'),
                FinancialIndependenceProgressCard(hasData: false),
              ],
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionTitle(title: 'Journey'),
                JourneyOverviewCard(hasData: false),
              ],
            ),
          ),
          AppSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SectionTitle(title: 'Quick Actions'),
                QuickActionsCard(
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
