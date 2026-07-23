import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Asset createAsset({
    String id = 'asset-1',
    String name = 'Asset One',
    String currencyCode = 'MYR',
  }) {
    return Asset(
      id: id,
      name: name,
      type: AssetType.stock,
      quantity: AssetQuantity('1'),
      unitPrice: AssetUnitPrice(amount: '1', currencyCode: currencyCode),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  Liability createLiability({
    String id = 'liability-1',
    String name = 'Liability One',
    String currencyCode = 'MYR',
  }) {
    return Liability(
      id: id,
      name: name,
      type: LiabilityType.personalLoan,
      outstandingBalance: LiabilityAmount(amount: '1', currencyCode: currencyCode),
      originalAmount: LiabilityAmount(amount: '1', currencyCode: currencyCode),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  Portfolio createPortfolio({
    String id = ' portfolio-1 ',
    String name = ' Main Portfolio ',
    List<Asset> assets = const <Asset>[],
    List<Liability> liabilities = const <Liability>[],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final DateTime creationTime = createdAt ?? DateTime(2026, 1, 1, 8);

    return Portfolio(
      id: id,
      name: name,
      assets: assets,
      liabilities: liabilities,
      createdAt: creationTime,
      updatedAt: updatedAt ?? creationTime,
    );
  }

  group('Portfolio', () {
    test('creates normalized portfolios with empty collections', () {
      final Portfolio portfolio = createPortfolio();

      expect(portfolio.id, 'portfolio-1');
      expect(portfolio.name, 'Main Portfolio');
      expect(portfolio.assets, isEmpty);
      expect(portfolio.liabilities, isEmpty);
    });

    test('preserves meaningful portfolio ID and name capitalization', () {
      final Portfolio portfolio = createPortfolio(
        id: ' FYQEN-Portfolio-001 ',
        name: ' Long Term Portfolio ',
      );

      expect(portfolio.id, 'FYQEN-Portfolio-001');
      expect(portfolio.name, 'Long Term Portfolio');
    });

    test('preserves child order and type-specific ID namespaces', () {
      final Asset firstAsset = createAsset(id: 'item-1');
      final Asset secondAsset = createAsset(id: 'asset-2');
      final Liability firstLiability = createLiability(id: 'item-1');
      final Liability secondLiability = createLiability(id: 'liability-2');
      final Portfolio portfolio = createPortfolio(
        assets: <Asset>[firstAsset, secondAsset],
        liabilities: <Liability>[firstLiability, secondLiability],
      );

      expect(portfolio.assets, <Asset>[firstAsset, secondAsset]);
      expect(portfolio.liabilities, <Liability>[firstLiability, secondLiability]);
      expect(identical(portfolio.assets.first, firstAsset), isTrue);
      expect(identical(portfolio.liabilities.first, firstLiability), isTrue);
    });

    test('rejects empty identifiers, names, duplicate assets, and liabilities', () {
      expect(() => createPortfolio(id: ''), throwsArgumentError);
      expect(() => createPortfolio(id: '  '), throwsArgumentError);
      expect(() => createPortfolio(name: ''), throwsArgumentError);
      expect(() => createPortfolio(name: '  '), throwsArgumentError);
      expect(
        () => createPortfolio(
          assets: <Asset>[createAsset(), createAsset(name: 'Different')],
        ),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message,
            'message',
            contains('asset-1'),
          ),
        ),
      );
      expect(
        () => createPortfolio(
          liabilities: <Liability>[
            createLiability(),
            createLiability(name: 'Different'),
          ],
        ),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message,
            'message',
            contains('liability-1'),
          ),
        ),
      );
    });

    test('defensively copies and exposes unmodifiable collections', () {
      final List<Asset> sourceAssets = <Asset>[createAsset()];
      final List<Liability> sourceLiabilities = <Liability>[createLiability()];
      final Portfolio portfolio = createPortfolio(
        assets: sourceAssets,
        liabilities: sourceLiabilities,
      );

      sourceAssets.add(createAsset(id: 'asset-2'));
      sourceLiabilities.add(createLiability(id: 'liability-2'));

      expect(portfolio.assets, hasLength(1));
      expect(portfolio.liabilities, hasLength(1));
      expect(() => portfolio.assets.add(createAsset(id: 'asset-3')), throwsUnsupportedError);
      expect(() => portfolio.assets.removeAt(0), throwsUnsupportedError);
      expect(() => portfolio.assets.clear(), throwsUnsupportedError);
      expect(
        () => portfolio.liabilities.add(createLiability(id: 'liability-3')),
        throwsUnsupportedError,
      );
      expect(() => portfolio.liabilities.removeAt(0), throwsUnsupportedError);
      expect(() => portfolio.liabilities.clear(), throwsUnsupportedError);
    });

    test('normalizes timestamps and rejects invalid timestamp order', () {
      final DateTime timestamp = DateTime(2026, 1, 1, 8);
      final Portfolio portfolio = createPortfolio(
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      expect(portfolio.createdAt.isUtc, isTrue);
      expect(portfolio.updatedAt.isUtc, isTrue);
      expect(portfolio.createdAt, portfolio.updatedAt);
      expect(
        () => createPortfolio(
          createdAt: DateTime.utc(2026, 1, 2),
          updatedAt: DateTime.utc(2026, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('does not require child timestamps to match portfolio timestamps', () {
      final Portfolio portfolio = createPortfolio(
        assets: <Asset>[createAsset()],
        liabilities: <Liability>[createLiability()],
        createdAt: DateTime.utc(2030, 1, 1),
        updatedAt: DateTime.utc(2030, 1, 1),
      );

      expect(portfolio.createdAt, DateTime.utc(2030, 1, 1));
    });

    test('uses normalized ID-only entity equality', () {
      final Portfolio first = createPortfolio();
      final Portfolio sameIdWithDifferentFields = createPortfolio(
        id: 'portfolio-1',
        name: 'Different Portfolio',
        assets: <Asset>[createAsset(currencyCode: 'USD')],
        liabilities: <Liability>[createLiability(currencyCode: 'USD')],
        createdAt: DateTime.utc(2020, 1, 1),
        updatedAt: DateTime.utc(2020, 1, 1),
      );
      final Portfolio differentId = createPortfolio(id: 'portfolio-2');

      expect(first, sameIdWithDifferentFields);
      expect(first.hashCode, sameIdWithDifferentFields.hashCode);
      expect(first, isNot(differentId));
    });

    test('has a concise count-only string representation', () {
      final Portfolio portfolio = createPortfolio(
        assets: <Asset>[createAsset()],
        liabilities: <Liability>[createLiability()],
      );
      final String description = portfolio.toString();

      expect(description, contains('portfolio-1'));
      expect(description, contains('Main Portfolio'));
      expect(description, contains('assetCount: 1'));
      expect(description, contains('liabilityCount: 1'));
      expect(description, isNot(contains('Asset(')));
      expect(description, isNot(contains('Liability(')));
    });
  });
}
