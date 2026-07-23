import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/dashboard/presentation/pages/dashboard_placeholder_page.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026);

  Portfolio portfolio({
    FinancialIndependenceTarget? target,
    String amount = '254',
    String? liabilityAmount,
    String liabilityCurrencyCode = 'MYR',
  }) {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: <Asset>[
        Asset(
          id: 'asset-1',
          name: 'Synthetic asset',
          type: AssetType.cash,
          quantity: AssetQuantity('1'),
          unitPrice: AssetUnitPrice(amount: amount, currencyCode: 'MYR'),
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
                  currencyCode: liabilityCurrencyCode,
                ),
                originalAmount: LiabilityAmount(
                  amount: liabilityAmount,
                  currencyCode: liabilityCurrencyCode,
                ),
                createdAt: timestamp,
                updatedAt: timestamp,
              ),
            ],
      financialIndependenceTarget: target,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  testWidgets('shows derived level progress without a second no-target CTA', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: DashboardPlaceholderPage(
          portfolio: portfolio(
            target: FinancialIndependenceTarget(
              amount: '1000',
              currencyCode: 'MYR',
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('financial-freedom-level-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('financial-freedom-current-level')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('financial-freedom-level-progress-percentage')),
      findsOneWidget,
    );
    expect(find.text('Level 25'), findsOneWidget);
    expect(find.text('40% toward Level 26'), findsOneWidget);
    expect(
      find.byKey(const Key('financial-freedom-next-level')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('financial-freedom-level-progress-indicator')),
      findsOneWidget,
    );
    final LinearProgressIndicator progressIndicator = tester
        .widget<LinearProgressIndicator>(
          find.byKey(const Key('financial-freedom-level-progress-indicator')),
        );
    expect(progressIndicator.value, 0.4);

    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      expect(
        find.bySemanticsLabel('Level 25. 40% toward Level 26'),
        findsOneWidget,
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets('keeps the level card hidden while FI target setup is required', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: DashboardPlaceholderPage(portfolio: portfolio()),
      ),
    );

    expect(find.byKey(const Key('financial-freedom-level-card')), findsNothing);
    expect(
      find.byKey(const Key('financial-independence-no-target-card')),
      findsOneWidget,
    );
  });

  testWidgets('shows the compact unavailable state for mixed currencies', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: DashboardPlaceholderPage(
          portfolio: portfolio(
            target: FinancialIndependenceTarget(
              amount: '1000',
              currencyCode: 'MYR',
            ),
            liabilityAmount: '1',
            liabilityCurrencyCode: 'USD',
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('financial-freedom-level-unavailable')),
      findsOneWidget,
    );
    expect(find.text('Level unavailable'), findsOneWidget);
  });

  testWidgets('shows the maximum state without a Level 101', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: DashboardPlaceholderPage(
          portfolio: portfolio(
            amount: '1000',
            target: FinancialIndependenceTarget(
              amount: '1000',
              currencyCode: 'MYR',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Level 100'), findsOneWidget);
    expect(find.text('Maximum level reached'), findsOneWidget);
    expect(find.byKey(const Key('financial-freedom-next-level')), findsNothing);
    expect(
      find.byKey(const Key('financial-freedom-maximum-level-message')),
      findsOneWidget,
    );
    final LinearProgressIndicator progressIndicator = tester
        .widget<LinearProgressIndicator>(
          find.byKey(const Key('financial-freedom-level-progress-indicator')),
        );
    expect(progressIndicator.value, 1);
  });

  testWidgets('updates from replacement Portfolio snapshots', (
    WidgetTester tester,
  ) async {
    Future<void> pumpDashboard({
      required String assetAmount,
      required String liabilityAmount,
      required String targetAmount,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: DashboardPlaceholderPage(
            portfolio: portfolio(
              amount: assetAmount,
              liabilityAmount: liabilityAmount,
              target: FinancialIndependenceTarget(
                amount: targetAmount,
                currencyCode: 'MYR',
              ),
            ),
          ),
        ),
      );
    }

    await pumpDashboard(
      assetAmount: '500',
      liabilityAmount: '100',
      targetAmount: '1000',
    );
    expect(find.text('Level 40'), findsOneWidget);

    await pumpDashboard(
      assetAmount: '600',
      liabilityAmount: '100',
      targetAmount: '1000',
    );
    expect(find.text('Level 50'), findsOneWidget);

    await pumpDashboard(
      assetAmount: '600',
      liabilityAmount: '200',
      targetAmount: '1000',
    );
    expect(find.text('Level 40'), findsOneWidget);

    await pumpDashboard(
      assetAmount: '600',
      liabilityAmount: '200',
      targetAmount: '800',
    );
    expect(find.text('Level 50'), findsOneWidget);
  });
}
