import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/enums/asset_type.dart';

void main() {
  test('AssetType values remain in the required order', () {
    expect(AssetType.values, <AssetType>[
      AssetType.cash,
      AssetType.savings,
      AssetType.fixedDeposit,
      AssetType.stock,
      AssetType.etf,
      AssetType.cryptocurrency,
      AssetType.property,
      AssetType.preciousMetal,
      AssetType.business,
      AssetType.retirement,
      AssetType.other,
    ]);
  });
}
