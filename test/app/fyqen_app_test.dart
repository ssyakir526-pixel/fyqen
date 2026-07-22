import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/fyqen_app.dart';
import 'package:fyqen/app/navigation/fyqen_shell.dart';
import 'package:fyqen/core/constants/app_constants.dart';
import 'package:fyqen/core/theme/app_colors.dart';
import 'package:fyqen/features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/financial_independence_progress_card.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/journey_overview_card.dart';
import 'package:fyqen/features/dashboard/presentation/widgets/net_worth_hero_card.dart';
import 'package:fyqen/shared/widgets/app_button.dart';
import 'package:fyqen/shared/widgets/section_title.dart';

void main() {
  testWidgets('renders the Dashboard layout foundation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FyqenApp());

    expect(find.byType(FyqenShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(6));
    expect(find.byType(DashboardPlaceholderPage), findsOneWidget);
    expect(find.text(AppConstants.appName), findsOneWidget);
    final List<SectionTitle> sectionTitles = tester
        .widgetList<SectionTitle>(find.byType(SectionTitle))
        .toList();
    final List<String> sectionLabels = sectionTitles
        .map((SectionTitle sectionTitle) => sectionTitle.title)
        .toList();
    final List<AppButton> quickActions = tester
        .widgetList<AppButton>(find.byType(AppButton))
        .toList();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(NetWorthHeroCard), findsOneWidget);
    expect(find.text('Net worth unavailable'), findsOneWidget);
    expect(find.byType(FinancialIndependenceProgressCard), findsOneWidget);
    expect(find.text('Progress unavailable'), findsOneWidget);
    expect(find.byType(JourneyOverviewCard), findsOneWidget);
    expect(find.text('Journey unavailable'), findsOneWidget);
    expect(
      sectionLabels,
      containsAll(<String>[
        'Net Worth',
        'Financial Independence',
        'Journey',
        'Quick Actions',
      ]),
    );
    expect(quickActions, hasLength(4));
    expect(
      quickActions.map((AppButton button) => button.label),
      containsAll(<String>[
        'Add Asset',
        'Add Liability',
        'View History',
        'Battle',
      ]),
    );
    expect(
      quickActions.every((AppButton button) => button.onPressed == null),
      isTrue,
    );
    expect(find.byType(MaterialApp), findsOneWidget);

    final NavigationBar navigationBar = tester.widget<NavigationBar>(
      find.byKey(const Key('fyqen_navigation_bar')),
    );
    final BuildContext scaffoldContext = tester.element(find.byType(Scaffold));
    final ThemeData theme = Theme.of(scaffoldContext);
    expect(navigationBar.selectedIndex, 0);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AppColors.background);
    expect(tester.takeException(), isNull);
  });
}
