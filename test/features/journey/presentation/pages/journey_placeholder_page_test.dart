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
    String? assetAmount,
    String? liabilityAmount,
    String? targetAmount,
    String assetCurrency = 'MYR',
    String liabilityCurrency = 'MYR',
  }) {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: assetAmount == null
          ? const <Asset>[]
          : <Asset>[
              Asset(
                id: 'asset-1',
                name: 'Synthetic asset',
                type: AssetType.cash,
                quantity: AssetQuantity('1'),
                unitPrice: AssetUnitPrice(
                  amount: assetAmount,
                  currencyCode: assetCurrency,
                ),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            ],
      liabilities: liabilityAmount == null
          ? const <Liability>[]
          : <Liability>[
              Liability(
                id: 'liability-1',
                name: 'Synthetic liability',
                type: LiabilityType.creditCard,
                outstandingBalance: LiabilityAmount(
                  amount: liabilityAmount,
                  currencyCode: liabilityCurrency,
                ),
                originalAmount: LiabilityAmount(
                  amount: liabilityAmount,
                  currencyCode: liabilityCurrency,
                ),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            ],
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

  Widget buildPage({
    Portfolio? portfolio,
    Future<bool> Function(FinancialIndependenceTarget target)? onSetTarget,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: JourneyPlaceholderPage(
        portfolio: portfolio,
        onSetFinancialIndependenceTarget: onSetTarget,
      ),
    );
  }

  testWidgets('shows one FI target setup action and reuses the target form', (
    WidgetTester tester,
  ) async {
    Future<bool> saveTarget(FinancialIndependenceTarget _) async => true;

    await tester.pumpWidget(
      buildPage(portfolio: portfolio(), onSetTarget: saveTarget),
    );

    expect(find.byKey(const Key('journey-page')), findsOneWidget);
    expect(find.text('Journey'), findsOneWidget);
    expect(find.text('Your path toward financial freedom.'), findsOneWidget);
    expect(find.byKey(const Key('journey-no-target-state')), findsOneWidget);
    expect(
      find.byKey(const Key('journey-set-fi-target-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('financial-independence-target-form')),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('journey-set-fi-target-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('financial-independence-target-form')),
      findsOneWidget,
    );
  });

  testWidgets('renders the available current position and all ten stages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildPage(
        portfolio: portfolio(assetAmount: '25.4', targetAmount: '100'),
      ),
    );

    expect(
      find.byKey(const Key('journey-current-position-card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('journey-current-level')), findsOneWidget);
    expect(find.text('Level 25'), findsOneWidget);
    expect(find.byKey(const Key('journey-current-stage')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('journey-current-stage'))).data,
      'Momentum',
    );
    expect(
      find.byKey(const Key('journey-overall-progress-percentage')),
      findsOneWidget,
    );
    expect(find.text('25% of FI target'), findsOneWidget);
    expect(find.byKey(const Key('journey-next-checkpoint')), findsOneWidget);
    expect(find.text('Next checkpoint: Level 30'), findsOneWidget);
    expect(find.byKey(const Key('journey-stage-timeline')), findsOneWidget);
    for (int stageNumber = 1; stageNumber <= 10; stageNumber += 1) {
      expect(find.byKey(Key('journey-stage-$stageNumber')), findsOneWidget);
      expect(
        find.byKey(Key('journey-stage-$stageNumber-status')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(const Key('journey-next-direction-card')),
      findsOneWidget,
    );
    expect(find.text('5 levels remain until Level 30.'), findsOneWidget);
    expect(
      find.byKey(const Key('journey-next-level-progress')),
      findsOneWidget,
    );
  });

  testWidgets('shows unavailable state for mixed currencies', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildPage(
        portfolio: portfolio(
          assetAmount: '100',
          liabilityAmount: '1',
          targetAmount: '1000',
          liabilityCurrency: 'USD',
        ),
      ),
    );

    expect(find.byKey(const Key('journey-unavailable-state')), findsOneWidget);
    expect(find.text('Journey unavailable'), findsOneWidget);
    expect(
      find.byKey(const Key('journey-current-position-card')),
      findsNothing,
    );
  });

  testWidgets('shows completion at Level 100 without a Level 101', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildPage(
        portfolio: portfolio(assetAmount: '100', targetAmount: '100'),
      ),
    );

    expect(find.text('Financial Freedom reached'), findsOneWidget);
    expect(find.text('Level 100'), findsOneWidget);
    expect(find.text('Journey complete'), findsOneWidget);
    expect(find.byKey(const Key('journey-current-stage')), findsNothing);
    expect(find.byKey(const Key('journey-complete-card')), findsOneWidget);
    expect(find.byKey(const Key('journey-complete-message')), findsOneWidget);
    expect(find.byKey(const Key('journey-next-direction-card')), findsNothing);
    expect(find.textContaining('Level 101'), findsNothing);
  });

  testWidgets('updates the first stage status at the Level 10 checkpoint', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildPage(
        portfolio: portfolio(assetAmount: '1', targetAmount: '100'),
      ),
    );

    expect(
      tester.widget<Text>(find.byKey(const Key('journey-stage-1-status'))).data,
      'Current',
    );

    await tester.pumpWidget(
      buildPage(
        portfolio: portfolio(assetAmount: '10', targetAmount: '100'),
      ),
    );

    expect(
      tester.widget<Text>(find.byKey(const Key('journey-stage-1-status'))).data,
      'Completed',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('journey-stage-2-status'))).data,
      'Current',
    );
  });

  testWidgets('updates from replacement shared Portfolio snapshots', (
    WidgetTester tester,
  ) async {
    Future<void> pumpJourney({
      String? assetAmount,
      String? liabilityAmount,
      String? targetAmount,
      String liabilityCurrency = 'MYR',
    }) {
      return tester.pumpWidget(
        buildPage(
          portfolio: portfolio(
            assetAmount: assetAmount,
            liabilityAmount: liabilityAmount,
            targetAmount: targetAmount,
            liabilityCurrency: liabilityCurrency,
          ),
        ),
      );
    }

    await pumpJourney();
    expect(find.byKey(const Key('journey-no-target-state')), findsOneWidget);

    await pumpJourney(
      assetAmount: '500',
      liabilityAmount: '100',
      targetAmount: '1000',
      liabilityCurrency: 'USD',
    );
    expect(find.byKey(const Key('journey-unavailable-state')), findsOneWidget);

    await pumpJourney(
      assetAmount: '500',
      liabilityAmount: '100',
      targetAmount: '1000',
    );
    expect(find.text('Level 40'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('journey-current-stage'))).data,
      'Halfway',
    );

    await pumpJourney(
      assetAmount: '600',
      liabilityAmount: '100',
      targetAmount: '1000',
    );
    expect(find.text('Level 50'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('journey-current-stage'))).data,
      'Expansion',
    );

    await pumpJourney(
      assetAmount: '500',
      liabilityAmount: '100',
      targetAmount: '1000',
    );
    expect(find.text('Level 40'), findsOneWidget);

    await pumpJourney(
      assetAmount: '500',
      liabilityAmount: '200',
      targetAmount: '1000',
    );
    expect(find.text('Level 30'), findsOneWidget);

    await pumpJourney(
      assetAmount: '500',
      liabilityAmount: '100',
      targetAmount: '1000',
    );
    expect(find.text('Level 40'), findsOneWidget);

    await pumpJourney(
      assetAmount: '500',
      liabilityAmount: '100',
      targetAmount: '400',
    );
    expect(find.text('Financial Freedom reached'), findsOneWidget);

    await pumpJourney(
      assetAmount: '500',
      liabilityAmount: '100',
      targetAmount: '1000',
    );
    expect(find.text('Level 40'), findsOneWidget);
  });

  testWidgets('builds semantics and scrolls on a small text-scaled surface', (
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
            child: JourneyPlaceholderPage(
              portfolio: portfolio(assetAmount: '25', targetAmount: '100'),
            ),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel(RegExp('Current position.*')),
        findsOneWidget,
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('journey-stage-10')), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}
