import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_asset_to_portfolio.dart';
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

  test('delegates asset append and propagates duplicate errors', () {
    final Asset existing = createAsset('asset-1');
    final Asset added = createAsset('asset-2');
    final Portfolio original = Portfolio(
      id: 'portfolio-1',
      name: 'Main',
      assets: <Asset>[existing],
      liabilities: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final Portfolio updated = const AddAssetToPortfolioUseCase()(
      portfolio: original,
      asset: added,
      updatedAt: DateTime.utc(2026, 1, 2),
    );

    expect(updated.assets, <Asset>[existing, added]);
    expect(identical(updated.assets.last, added), isTrue);
    expect(original.assets, <Asset>[existing]);
    expect(() => updated.assets.clear(), throwsUnsupportedError);
    expect(
      () => const AddAssetToPortfolioUseCase()(
        portfolio: original,
        asset: existing,
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
      throwsArgumentError,
    );
  });
}
