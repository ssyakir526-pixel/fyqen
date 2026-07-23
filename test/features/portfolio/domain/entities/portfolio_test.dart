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
      outstandingBalance: LiabilityAmount(
        amount: '1',
        currencyCode: currencyCode,
      ),
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
      expect(portfolio.liabilities, <Liability>[
        firstLiability,
        secondLiability,
      ]);
      expect(identical(portfolio.assets.first, firstAsset), isTrue);
      expect(identical(portfolio.liabilities.first, firstLiability), isTrue);
    });

    test(
      'rejects empty identifiers, names, duplicate assets, and liabilities',
      () {
        expect(() => createPortfolio(id: ''), throwsArgumentError);
        expect(() => createPortfolio(id: '  '), throwsArgumentError);
        expect(() => createPortfolio(name: ''), throwsArgumentError);
        expect(() => createPortfolio(name: '  '), throwsArgumentError);
        expect(
          () => createPortfolio(
            assets: <Asset>[
              createAsset(),
              createAsset(name: 'Different'),
            ],
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
      },
    );

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
      expect(
        () => portfolio.assets.add(createAsset(id: 'asset-3')),
        throwsUnsupportedError,
      );
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

  group('Portfolio immutable modification contract', () {
    final DateTime equalUpdateTime = DateTime.utc(2026, 1, 1, 8);
    final DateTime laterUpdateTime = DateTime.utc(2026, 1, 2, 8);

    test('renames through a new snapshot while preserving aggregate data', () {
      final Asset asset = createAsset();
      final Liability liability = createLiability();
      final Portfolio original = createPortfolio(
        assets: <Asset>[asset],
        liabilities: <Liability>[liability],
        updatedAt: equalUpdateTime,
      );
      final Portfolio renamed = original.rename(
        name: ' Updated Portfolio ',
        updatedAt: laterUpdateTime,
      );

      expect(identical(original, renamed), isFalse);
      expect(renamed.name, 'Updated Portfolio');
      expect(renamed.id, original.id);
      expect(renamed.createdAt, original.createdAt);
      expect(identical(renamed.assets.single, asset), isTrue);
      expect(identical(renamed.liabilities.single, liability), isTrue);
      expect(original.name, 'Main Portfolio');
      expect(renamed, original);
      expect(renamed.hashCode, original.hashCode);
      expect(
        () => original.rename(name: '', updatedAt: laterUpdateTime),
        throwsArgumentError,
      );
      expect(
        () => original.rename(
          name: 'Earlier',
          updatedAt: DateTime.utc(2026, 1, 1, 7),
        ),
        throwsArgumentError,
      );
    });

    test('adds assets by appending without changing the original snapshot', () {
      final Asset existingAsset = createAsset();
      final Liability liability = createLiability(id: 'shared-id');
      final Asset addedAsset = createAsset(id: 'shared-id');
      final Portfolio original = createPortfolio(
        assets: <Asset>[existingAsset],
        liabilities: <Liability>[liability],
        updatedAt: equalUpdateTime,
      );
      final Portfolio updated = original.addAsset(
        asset: addedAsset,
        updatedAt: laterUpdateTime,
      );

      expect(updated.assets, <Asset>[existingAsset, addedAsset]);
      expect(identical(updated.assets.last, addedAsset), isTrue);
      expect(updated.liabilities, <Liability>[liability]);
      expect(original.assets, <Asset>[existingAsset]);
      expect(updated.updatedAt, laterUpdateTime);
      expect(updated.updatedAt.isUtc, isTrue);
      expect(
        () =>
            original.addAsset(asset: existingAsset, updatedAt: laterUpdateTime),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message,
            'message',
            contains('asset-1'),
          ),
        ),
      );
      expect(
        () => original.addAsset(
          asset: addedAsset,
          updatedAt: DateTime.utc(2026, 1, 1, 7),
        ),
        throwsArgumentError,
      );
    });

    test('replaces assets in place and rejects missing IDs', () {
      final Asset firstAsset = createAsset(id: 'asset-1');
      final Asset secondAsset = createAsset(id: 'asset-2');
      final Asset replacement = createAsset(id: 'asset-1', name: 'Replacement');
      final Portfolio original = createPortfolio(
        assets: <Asset>[firstAsset, secondAsset],
        updatedAt: equalUpdateTime,
      );
      final Portfolio updated = original.replaceAsset(
        asset: replacement,
        updatedAt: equalUpdateTime,
      );

      expect(updated.assets, <Asset>[replacement, secondAsset]);
      expect(identical(updated.assets.first, replacement), isTrue);
      expect(identical(updated.assets.last, secondAsset), isTrue);
      expect(original.assets, <Asset>[firstAsset, secondAsset]);
      expect(
        () => original.replaceAsset(
          asset: createAsset(id: 'missing-asset'),
          updatedAt: laterUpdateTime,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message,
            'message',
            contains('missing-asset'),
          ),
        ),
      );
    });

    test('removes assets by trimmed case-sensitive IDs', () {
      final Asset firstAsset = createAsset(id: 'Asset-1');
      final Asset secondAsset = createAsset(id: 'asset-2');
      final Portfolio original = createPortfolio(
        assets: <Asset>[firstAsset, secondAsset],
        updatedAt: equalUpdateTime,
      );
      final Portfolio updated = original.removeAsset(
        assetId: ' Asset-1 ',
        updatedAt: laterUpdateTime,
      );

      expect(updated.assets, <Asset>[secondAsset]);
      expect(original.assets, <Asset>[firstAsset, secondAsset]);
      expect(
        () =>
            updated.removeAsset(assetId: 'asset-2', updatedAt: laterUpdateTime),
        returnsNormally,
      );
      expect(
        () => original.removeAsset(assetId: '', updatedAt: laterUpdateTime),
        throwsArgumentError,
      );
      expect(
        () => original.removeAsset(
          assetId: 'asset-1',
          updatedAt: laterUpdateTime,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message,
            'message',
            contains('asset-1'),
          ),
        ),
      );
    });

    test(
      'adds liabilities by appending without changing the original snapshot',
      () {
        final Liability existingLiability = createLiability();
        final Asset asset = createAsset(id: 'shared-id');
        final Liability addedLiability = createLiability(id: 'shared-id');
        final Portfolio original = createPortfolio(
          assets: <Asset>[asset],
          liabilities: <Liability>[existingLiability],
          updatedAt: equalUpdateTime,
        );
        final Portfolio updated = original.addLiability(
          liability: addedLiability,
          updatedAt: laterUpdateTime,
        );

        expect(updated.liabilities, <Liability>[
          existingLiability,
          addedLiability,
        ]);
        expect(identical(updated.liabilities.last, addedLiability), isTrue);
        expect(updated.assets, <Asset>[asset]);
        expect(original.liabilities, <Liability>[existingLiability]);
        expect(
          () => original.addLiability(
            liability: existingLiability,
            updatedAt: laterUpdateTime,
          ),
          throwsA(
            isA<ArgumentError>().having(
              (ArgumentError error) => error.message,
              'message',
              contains('liability-1'),
            ),
          ),
        );
      },
    );

    test('replaces liabilities in place and rejects missing IDs', () {
      final Liability firstLiability = createLiability(id: 'liability-1');
      final Liability secondLiability = createLiability(id: 'liability-2');
      final Liability replacement = createLiability(
        id: 'liability-1',
        name: 'Replacement',
      );
      final Portfolio original = createPortfolio(
        liabilities: <Liability>[firstLiability, secondLiability],
        updatedAt: equalUpdateTime,
      );
      final Portfolio updated = original.replaceLiability(
        liability: replacement,
        updatedAt: equalUpdateTime,
      );

      expect(updated.liabilities, <Liability>[replacement, secondLiability]);
      expect(identical(updated.liabilities.first, replacement), isTrue);
      expect(identical(updated.liabilities.last, secondLiability), isTrue);
      expect(
        () => original.replaceLiability(
          liability: createLiability(id: 'missing-liability'),
          updatedAt: laterUpdateTime,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message,
            'message',
            contains('missing-liability'),
          ),
        ),
      );
    });

    test('removes liabilities by trimmed case-sensitive IDs', () {
      final Liability firstLiability = createLiability(id: 'Liability-1');
      final Liability secondLiability = createLiability(id: 'liability-2');
      final Portfolio original = createPortfolio(
        liabilities: <Liability>[firstLiability, secondLiability],
        updatedAt: equalUpdateTime,
      );
      final Portfolio updated = original.removeLiability(
        liabilityId: ' Liability-1 ',
        updatedAt: laterUpdateTime,
      );

      expect(updated.liabilities, <Liability>[secondLiability]);
      expect(original.liabilities, <Liability>[
        firstLiability,
        secondLiability,
      ]);
      expect(
        () => original.removeLiability(
          liabilityId: '   ',
          updatedAt: laterUpdateTime,
        ),
        throwsArgumentError,
      );
      expect(
        () => original.removeLiability(
          liabilityId: 'liability-1',
          updatedAt: laterUpdateTime,
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

    test(
      'returns unmodifiable modified collections and keeps child times independent',
      () {
        final Portfolio original = createPortfolio(updatedAt: equalUpdateTime);
        final Portfolio updated = original.addAsset(
          asset: createAsset(currencyCode: 'USD'),
          updatedAt: laterUpdateTime,
        );

        expect(identical(original, updated), isFalse);
        expect(updated, original);
        expect(updated.hashCode, original.hashCode);
        expect(updated.createdAt, original.createdAt);
        expect(() => updated.assets.clear(), throwsUnsupportedError);
        expect(() => updated.liabilities.clear(), throwsUnsupportedError);
      },
    );
  });
}
