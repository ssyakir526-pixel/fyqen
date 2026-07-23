import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/pages/portfolio_management_page.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026, 1, 1);

  Portfolio portfolio() {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: const <Asset>[],
      liabilities: const <Liability>[],
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  testWidgets('keeps Assets and Liabilities in the Portfolio destination', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: PortfolioManagementPage(
          portfolio: portfolio(),
          isSaving: false,
          onAddAsset: (Asset asset) async => true,
          onReplaceAsset: (Asset asset) async => true,
          onRemoveAsset: (String assetId) async => true,
          onAddLiability: (Liability liability) async => true,
          onReplaceLiability: (Liability liability) async => true,
          onRemoveLiability: (String liabilityId) async => true,
          createAssetId: () => 'asset-created',
          createLiabilityId: () => 'liability-created',
          currentTime: () => timestamp,
        ),
      ),
    );

    expect(find.text('Portfolio'), findsOneWidget);
    expect(find.text('Assets'), findsOneWidget);
    expect(find.text('Liabilities'), findsOneWidget);

    await tester.tap(find.text('Liabilities'));
    await tester.pumpAndSettle();
    expect(find.text('No liabilities yet'), findsOneWidget);
  });
}
