import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_asset_from_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Asset createAsset(String id) => Asset(
    id: id,
    name: id,
    type: AssetType.stock,
    quantity: AssetQuantity('1'),
    unitPrice: AssetUnitPrice(amount: '1', currencyCode: 'MYR'),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('delegates asset removal with aggregate ID normalization', () {
    final Asset asset = createAsset('Asset-1');
    final Portfolio original = Portfolio(
      id: 'portfolio-1',
      name: 'Main',
      assets: <Asset>[asset],
      liabilities: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final Portfolio updated = const RemoveAssetFromPortfolioUseCase()(
      portfolio: original,
      assetId: ' Asset-1 ',
      updatedAt: DateTime.utc(2026),
    );

    expect(updated.assets, isEmpty);
    expect(original.assets, <Asset>[asset]);
    expect(
      () => const RemoveAssetFromPortfolioUseCase()(
        portfolio: original,
        assetId: 'asset-1',
        updatedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
    expect(
      () => const RemoveAssetFromPortfolioUseCase()(
        portfolio: original,
        assetId: '',
        updatedAt: DateTime.utc(2026),
      ),
      throwsArgumentError,
    );
  });
}
