import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/pages/liabilities_page.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026, 1, 1);

  Liability liability({
    String id = 'liability-1',
    String currencyCode = 'MYR',
  }) {
    return Liability(
      id: id,
      name: 'Synthetic card balance',
      type: LiabilityType.creditCard,
      outstandingBalance: LiabilityAmount(
        amount: '50',
        currencyCode: currencyCode,
      ),
      originalAmount: LiabilityAmount(
        amount: '100',
        currencyCode: currencyCode,
      ),
      lenderName: 'Synthetic lender',
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Portfolio portfolio({List<Liability> liabilities = const <Liability>[]}) {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: const [],
      liabilities: liabilities,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Widget buildPage({
    required Portfolio currentPortfolio,
    Future<bool> Function(Liability liability)? onAddLiability,
    Future<bool> Function(Liability liability)? onReplaceLiability,
    Future<bool> Function(String liabilityId)? onRemoveLiability,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: LiabilitiesPage(
        portfolio: currentPortfolio,
        onAddLiability: onAddLiability ?? (Liability liability) async => true,
        onReplaceLiability:
            onReplaceLiability ?? (Liability liability) async => true,
        onRemoveLiability:
            onRemoveLiability ?? (String liabilityId) async => true,
        createLiabilityId: () => 'liability-created',
        currentTime: () => timestamp,
      ),
    );
  }

  testWidgets('shows an actionable empty Liability state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage(currentPortfolio: portfolio()));

    expect(find.text('No liabilities yet'), findsOneWidget);
    expect(
      find.text('Add a liability to keep your net worth calculation accurate.'),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('liabilities-empty-state-add-button')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('liability-form')), findsOneWidget);
  });

  testWidgets('shows immutable Liability details and requires confirmation', (
    WidgetTester tester,
  ) async {
    int deleteCalls = 0;
    await tester.pumpWidget(
      buildPage(
        currentPortfolio: portfolio(liabilities: <Liability>[liability()]),
        onRemoveLiability: (String liabilityId) async {
          deleteCalls += 1;
          return true;
        },
      ),
    );

    final Finder row = find.byKey(const Key('liability-list-item-liability-1'));
    expect(row, findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.textContaining('MYR 50')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('delete-liability-button-liability-1')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delete-liability-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('cancel-delete-liability-button')));
    await tester.pumpAndSettle();
    expect(deleteCalls, 0);
  });

  testWidgets('uses safe totals when Liability currencies are mixed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildPage(
        currentPortfolio: portfolio(
          liabilities: <Liability>[
            liability(currencyCode: 'MYR'),
            liability(id: 'liability-2', currencyCode: 'USD'),
          ],
        ),
      ),
    );

    expect(
      find.textContaining('Unavailable across currencies'),
      findsOneWidget,
    );
  });
}
