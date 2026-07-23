import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/journey/presentation/pages/journey_placeholder_page.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026);

  Portfolio portfolio({
    int assetCount = 0,
    String assetAmount = '1',
    String? targetAmount,
    bool mixedCurrencies = false,
  }) {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: List<Asset>.generate(
        assetCount,
        (int index) => Asset(
          id: 'asset-$index',
          name: 'Asset $index',
          type: AssetType.cash,
          quantity: AssetQuantity('1'),
          unitPrice: AssetUnitPrice(
            amount: index == 0 ? assetAmount : '1',
            currencyCode: 'MYR',
          ),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      ),
      liabilities: mixedCurrencies
          ? <Liability>[
              Liability(
                id: 'liability',
                name: 'Mixed liability',
                type: LiabilityType.creditCard,
                outstandingBalance: LiabilityAmount(
                  amount: '1',
                  currencyCode: 'USD',
                ),
                originalAmount: LiabilityAmount(
                  amount: '1',
                  currencyCode: 'USD',
                ),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            ]
          : const <Liability>[],
      financialIndependenceTarget: targetAmount == null
          ? null
          : FinancialIndependenceTarget(
              amount: targetAmount,
              currencyCode: 'MYR',
            ),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Widget buildPage(Portfolio portfolio) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: JourneyPlaceholderPage(portfolio: portfolio),
    );
  }

  testWidgets('renders the derived Challenge section and fixed catalog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage(portfolio()));

    expect(find.byKey(const Key('journey-challenge-section')), findsOneWidget);
    expect(find.byKey(const Key('journey-challenge-heading')), findsOneWidget);
    expect(
      find.byKey(const Key('journey-challenge-supporting-text')),
      findsOneWidget,
    );
    expect(
      find.text('A measurable next step based on your current Portfolio.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('journey-challenge-overview-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('journey-challenge-completed-count')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('journey-challenge-overall-progress')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('journey-challenge-progress-indicator')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('journey-current-challenge-card')),
      findsOneWidget,
    );
    expect(find.text('Set Your FI Target'), findsNWidgets(2));
    expect(find.text('Active'), findsWidgets);

    for (final String id in <String>[
      'set-fi-target',
      'add-first-asset',
      'track-three-assets',
      'reach-level-10',
      'reach-level-25',
      'complete-three-journey-stages',
      'complete-five-journey-stages',
      'reach-financial-freedom',
    ]) {
      expect(find.byKey(Key('challenge-$id')), findsOneWidget);
      expect(find.byKey(Key('challenge-$id-title')), findsOneWidget);
      expect(find.byKey(Key('challenge-$id-status')), findsOneWidget);
    }
  });

  testWidgets(
    'shows safe unavailable financial progress without hiding assets',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildPage(
          portfolio(assetCount: 3, targetAmount: '100', mixedCurrencies: true),
        ),
      );

      expect(find.text('Unavailable'), findsWidgets);
      expect(
        find.byKey(const Key('challenge-reach-level-10-unavailable-reason')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('journey-current-challenge-unavailable-reason')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const Key('journey-current-challenge-unavailable-reason'),
          ),
          matching: find.text('Financial Freedom Level is unavailable.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const Key('challenge-reach-level-10-unavailable-reason'),
          ),
          matching: find.text('Financial Freedom Level is unavailable.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(
            const Key('challenge-reach-level-25-unavailable-reason'),
          ),
          matching: find.text('Financial Freedom Level is unavailable.'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('challenge-track-three-assets-progress')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('challenge-add-first-asset-status')),
            )
            .data,
        'Portfolio - Completed',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const Key('challenge-track-three-assets-status')),
            )
            .data,
        'Portfolio - Completed',
      );
      for (final String id in <String>[
        'reach-level-10',
        'reach-level-25',
        'complete-three-journey-stages',
        'complete-five-journey-stages',
        'reach-financial-freedom',
      ]) {
        expect(
          find.byKey(Key('challenge-$id-unavailable-reason')),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('updates Challenge status from replacement Portfolio snapshots', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage(portfolio(targetAmount: '100')));
    expect(find.text('Add Your First Asset'), findsNWidgets(2));
    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('journey-current-challenge-title')),
          )
          .data,
      'Add Your First Asset',
    );

    await tester.pumpWidget(
      buildPage(portfolio(assetCount: 1, targetAmount: '100')),
    );
    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('journey-current-challenge-title')),
          )
          .data,
      'Build Your Portfolio',
    );

    await tester.pumpWidget(buildPage(portfolio(targetAmount: '100')));
    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('journey-current-challenge-title')),
          )
          .data,
      'Add Your First Asset',
    );
  });

  testWidgets('shows the all-completed state at Financial Freedom', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildPage(
        portfolio(assetCount: 3, assetAmount: '98', targetAmount: '100'),
      ),
    );

    expect(
      find.byKey(const Key('journey-all-challenges-completed')),
      findsOneWidget,
    );
    expect(find.text('All Challenges Completed'), findsOneWidget);
    expect(
      find.byKey(const Key('journey-current-challenge-card')),
      findsNothing,
    );
  });

  testWidgets(
    'supports semantics and scrolling on a small large-text surface',
    (WidgetTester tester) async {
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
              child: JourneyPlaceholderPage(
                portfolio: portfolio(assetCount: 1, targetAmount: '100'),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel('Build Your Portfolio. Active. 1 of 3 assets'),
          findsNWidgets(2),
        );
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -900),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('challenge-reach-financial-freedom')),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );
}
