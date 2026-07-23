import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/achievements/presentation/pages/achievements_page.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026);

  Portfolio portfolio({int assets = 0, String? amount, String? target}) {
    return Portfolio(
      id: 'portfolio',
      name: 'Portfolio',
      assets: List<Asset>.generate(
        assets,
        (int index) => Asset(
          id: 'asset-$index',
          name: 'Asset $index',
          type: AssetType.cash,
          quantity: AssetQuantity('1'),
          unitPrice: AssetUnitPrice(amount: amount ?? '1', currencyCode: 'MYR'),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      ),
      liabilities: const [],
      financialIndependenceTarget: target == null
          ? null
          : FinancialIndependenceTarget(amount: target, currencyCode: 'MYR'),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Widget buildPage(Portfolio portfolio) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: AchievementsPage(portfolio: portfolio),
    );
  }

  testWidgets('renders the complete revocable catalog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage(portfolio(assets: 1)));

    expect(find.byKey(const Key('achievements-page')), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
    expect(
      find.text('Milestones based on your current financial progress.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('achievements-overview-card')), findsOneWidget);
    expect(find.byKey(const Key('achievements-earned-count')), findsOneWidget);
    expect(
      find.byKey(const Key('achievements-revocable-info')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('achievements-portfolio-section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('achievements-progress-section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('achievements-journey-section')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('achievements-financial-freedom-section')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('achievement-first-asset')), findsOneWidget);
    expect(
      find.byKey(const Key('achievement-financial-freedom-reached')),
      findsOneWidget,
    );
    expect(find.text('Earned'), findsWidgets);
    expect(find.text('Not earned'), findsWidgets);
    expect(find.text('Unavailable'), findsWidgets);
  });

  testWidgets('updates earned status from replacement Portfolio snapshots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage(portfolio(assets: 0)));
    expect(
      tester
          .widget<Text>(find.byKey(const Key('achievement-first-asset-status')))
          .data,
      'Not earned',
    );

    await tester.pumpWidget(buildPage(portfolio(assets: 1)));
    expect(
      tester
          .widget<Text>(find.byKey(const Key('achievement-first-asset-status')))
          .data,
      'Earned',
    );

    await tester.pumpWidget(
      buildPage(portfolio(assets: 1, amount: '100', target: '100')),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const Key('achievement-financial-freedom-reached-status'),
            ),
          )
          .data,
      'Earned',
    );

    await tester.pumpWidget(
      buildPage(portfolio(assets: 1, amount: '99', target: '100')),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(
              const Key('achievement-financial-freedom-reached-status'),
            ),
          )
          .data,
      'Not earned',
    );
  });

  testWidgets('builds semantics on a small scrolling surface', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.5),
            ),
            child: AchievementsPage(portfolio: portfolio(assets: 1)),
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('First Asset. Earned. 1 of 1 assets.'),
        findsOneWidget,
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('achievement-financial-freedom-reached')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
