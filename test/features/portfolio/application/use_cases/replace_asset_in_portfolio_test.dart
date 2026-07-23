import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_asset_in_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Asset createAsset(String id, String name) => Asset(
    id: id,
    name: name,
    type: AssetType.stock,
    quantity: AssetQuantity('1'),
    unitPrice: AssetUnitPrice(amount: '1', currencyCode: 'MYR'),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('delegates in-place asset replacement and propagates missing IDs', () {
    final Asset first = createAsset('asset-1', 'First');
    final Asset second = createAsset('asset-2', 'Second');
    final Asset replacement = createAsset('asset-1', 'Replacement');
    final Portfolio original = Portfolio(
      id: 'portfolio-1', name: 'Main', assets: <Asset>[first, second],
      liabilities: const [], createdAt: DateTime.utc(2026), updatedAt: DateTime.utc(2026),
    );
    final Portfolio updated = const ReplaceAssetInPortfolioUseCase()(
      portfolio: original, asset: replacement, updatedAt: DateTime.utc(2026),
    );

    expect(updated.assets, <Asset>[replacement, second]);
    expect(identical(updated.assets.first, replacement), isTrue);
    expect(original.assets, <Asset>[first, second]);
    expect(
      () => const ReplaceAssetInPortfolioUseCase()(
        portfolio: original, asset: createAsset('missing', 'Missing'), updatedAt: DateTime.utc(2026),
      ), throwsArgumentError,
    );
  });
}
