import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/section_title.dart';
import '../widgets/financial_independence_progress_card.dart';
import '../widgets/journey_overview_card.dart';
import '../widgets/net_worth_hero_card.dart';

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
                AppCard(
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: <Widget>[
                      AppButton(
                        label: 'Add Asset',
                        onPressed: null,
                        expand: false,
                      ),
                      AppButton(
                        label: 'Add Liability',
                        onPressed: null,
                        expand: false,
                      ),
                      AppButton(
                        label: 'View History',
                        onPressed: null,
                        expand: false,
                      ),
                      AppButton(
                        label: 'Battle',
                        onPressed: null,
                        expand: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
