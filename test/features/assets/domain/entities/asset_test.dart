import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';

void main() {
  Asset createAsset({
    String id = ' asset-1 ',
    String name = ' Bitcoin ',
    String? symbol = ' BTC ',
    AssetQuantity? quantity,
    AssetUnitPrice? unitPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final DateTime creationTime = createdAt ?? DateTime(2026, 1, 1, 8);

    return Asset(
      id: id,
      name: name,
      type: AssetType.cryptocurrency,
      quantity: quantity ?? AssetQuantity('1'),
      unitPrice: unitPrice ?? AssetUnitPrice(amount: '1', currencyCode: 'MYR'),
      createdAt: creationTime,
      updatedAt: updatedAt ?? creationTime,
      symbol: symbol,
    );
  }

  group('Asset', () {
    test('creates a normalized immutable entity', () {
      final Asset asset = createAsset();

      expect(asset.id, 'asset-1');
      expect(asset.name, 'Bitcoin');
      expect(asset.symbol, 'BTC');
      expect(asset.type, AssetType.cryptocurrency);
    });

    test('normalizes optional symbols without changing capitalization', () {
      expect(createAsset(symbol: ' aApL ').symbol, 'aApL');
      expect(createAsset(symbol: '  ').symbol, isNull);
      expect(createAsset(symbol: null).symbol, isNull);
    });

    test('normalizes timestamps to UTC and permits equal timestamps', () {
      final DateTime timestamp = DateTime(2026, 1, 1, 8);
      final Asset asset = createAsset(
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      expect(asset.createdAt.isUtc, isTrue);
      expect(asset.updatedAt.isUtc, isTrue);
      expect(asset.createdAt, asset.updatedAt);
    });

    test('rejects empty and whitespace identity or name values', () {
      expect(() => createAsset(id: ''), throwsArgumentError);
      expect(() => createAsset(id: '  '), throwsArgumentError);
      expect(() => createAsset(name: ''), throwsArgumentError);
      expect(() => createAsset(name: '  '), throwsArgumentError);
    });

    test('rejects updated timestamps earlier than creation timestamps', () {
      expect(
        () => createAsset(
          createdAt: DateTime.utc(2026, 1, 2),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('uses normalized ID-only entity equality', () {
      final Asset first = createAsset();
      final Asset sameIdWithDifferentFields = createAsset(
        id: 'asset-1',
        name: 'Different name',
        quantity: AssetQuantity('2'),
        unitPrice: AssetUnitPrice(amount: '3', currencyCode: 'USD'),
      );
      final Asset differentId = createAsset(id: 'asset-2');

      expect(first, sameIdWithDifferentFields);
      expect(first.hashCode, sameIdWithDifferentFields.hashCode);
      expect(first, isNot(differentId));
    });

    test('has a concise developer-readable string representation', () {
      final String description = createAsset().toString();

      expect(description, contains('asset-1'));
      expect(description, contains('Bitcoin'));
      expect(description, contains('AssetType.cryptocurrency'));
      expect(description, isNot(contains('quantity')));
      expect(description, isNot(contains('unitPrice')));
    });
  });
}
