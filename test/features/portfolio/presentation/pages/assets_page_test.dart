import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/core/theme/app_theme.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/pages/assets_page.dart';

void main() {
  final DateTime timestamp = DateTime.utc(2026, 1, 1);

  Portfolio portfolio({List<Asset> assets = const <Asset>[]}) {
    return Portfolio(
      id: 'primary',
      name: 'My Portfolio',
      assets: assets,
      liabilities: const [],
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Asset asset() {
    return Asset(
      id: 'asset-1',
      name: 'Savings account',
      symbol: 'SAVE',
      type: AssetType.savings,
      quantity: AssetQuantity('2'),
      unitPrice: AssetUnitPrice(amount: '25', currencyCode: 'MYR'),
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Widget buildPage({
    required Portfolio currentPortfolio,
    Future<bool> Function(Asset asset)? onAddAsset,
    Future<bool> Function(Asset asset)? onReplaceAsset,
    Future<bool> Function(String assetId)? onRemoveAsset,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: AssetsPage(
        portfolio: currentPortfolio,
        onAddAsset: onAddAsset ?? (Asset asset) async => true,
        onReplaceAsset: onReplaceAsset ?? (Asset asset) async => true,
        onRemoveAsset: onRemoveAsset ?? (String assetId) async => true,
        createAssetId: () => 'asset-created',
        currentTime: () => timestamp,
      ),
    );
  }

  testWidgets('shows an actionable empty Asset state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildPage(currentPortfolio: portfolio()));

    expect(find.text('No assets yet'), findsOneWidget);
    expect(
      find.text('Add your first asset to start tracking your portfolio.'),
      findsOneWidget,
    );

    expect(
      find.byKey(const Key('assets-empty-state-add-button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('assets-empty-state-add-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('asset-form')), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(5));
  });

  testWidgets(
    'shows immutable Asset details and requires delete confirmation',
    (WidgetTester tester) async {
      int deleteCalls = 0;
      await tester.pumpWidget(
        buildPage(
          currentPortfolio: portfolio(assets: <Asset>[asset()]),
          onRemoveAsset: (String assetId) async {
            deleteCalls += 1;
            return true;
          },
        ),
      );

      expect(find.text('Savings account • SAVE'), findsOneWidget);
      final Finder assetRow = find.byKey(const Key('asset-list-item-asset-1'));
      expect(assetRow, findsOneWidget);
      expect(
        find.descendant(
          of: assetRow,
          matching: find.textContaining('Total: MYR 50'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Delete asset'));
      await tester.pumpAndSettle();
      expect(find.text('Delete asset?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(deleteCalls, 0);
    },
  );
}
