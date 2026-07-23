import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';
import 'package:fyqen/features/portfolio/infrastructure/errors/portfolio_data_mapping_exception.dart';
import 'package:fyqen/features/portfolio/infrastructure/mappers/portfolio_mapper.dart';

void main() {
  const PortfolioMapper mapper = PortfolioMapper();

  Asset asset({
    String id = 'asset-1',
    AssetType type = AssetType.stock,
    String quantity = '1.2300',
    String unitPrice = '999999999999999999999999.000000000000000001',
    String currencyCode = 'MYR',
  }) {
    return Asset(
      id: id,
      name: 'Asset $id',
      type: type,
      quantity: AssetQuantity(quantity),
      unitPrice: AssetUnitPrice(amount: unitPrice, currencyCode: currencyCode),
      createdAt: DateTime.utc(2026, 1, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2, 1),
      symbol: 'SYM$id',
    );
  }

  Liability liability({
    String id = 'liability-1',
    LiabilityType type = LiabilityType.personalLoan,
    String currencyCode = 'USD',
  }) {
    return Liability(
      id: id,
      name: 'Liability $id',
      type: type,
      outstandingBalance: LiabilityAmount(
        amount: '0.010000000000000001',
        currencyCode: currencyCode,
      ),
      originalAmount: LiabilityAmount(
        amount: '1000000000000000000000',
        currencyCode: currencyCode,
      ),
      createdAt: DateTime.utc(2026, 1, 3, 1),
      updatedAt: DateTime.utc(2026, 1, 4, 1),
      lenderName: 'Lender $id',
      dueDate: DateTime.utc(2027, 1, 1),
    );
  }

  Portfolio portfolio({
    List<Asset> assets = const <Asset>[],
    List<Liability> liabilities = const <Liability>[],
    FinancialIndependenceTarget? financialIndependenceTarget,
  }) {
    return Portfolio(
      id: 'portfolio-1',
      name: 'Main Portfolio',
      assets: assets,
      liabilities: liabilities,
      financialIndependenceTarget: financialIndependenceTarget,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 2),
    );
  }

  Matcher mappingErrorAt(String path) {
    return isA<PortfolioDataMappingException>().having(
      (PortfolioDataMappingException error) => error.path,
      'path',
      path,
    );
  }

  group('PortfolioMapper', () {
    test('maps an empty aggregate to the version 1 schema and back', () {
      final Portfolio original = portfolio();
      final Map<String, Object?> map = mapper.toMap(original);
      final Portfolio reconstructed = mapper.fromMap(map);

      expect(map['schemaVersion'], 1);
      expect(map['createdAt'], '2026-01-01T00:00:00.000Z');
      expect(map['updatedAt'], '2026-01-02T00:00:00.000Z');
      expect(map['assets'], isEmpty);
      expect(map['liabilities'], isEmpty);
      expect(map['financialIndependenceTarget'], isNull);
      expect(identical(original, reconstructed), isFalse);
      expect(reconstructed.id, original.id);
      expect(reconstructed.name, original.name);
      expect(reconstructed.createdAt, original.createdAt);
      expect(reconstructed.updatedAt, original.updatedAt);
    });

    test('round-trips an optional exact Financial Independence target', () {
      final Portfolio original = portfolio(
        financialIndependenceTarget: FinancialIndependenceTarget(
          amount: '1000.50',
          currencyCode: 'myr',
        ),
      );

      final Map<String, Object?> map = mapper.toMap(original);
      final Portfolio reconstructed = mapper.fromMap(map);

      expect(map['financialIndependenceTarget'], <String, Object?>{
        'amount': '1000.5',
        'currencyCode': 'MYR',
      });
      expect(
        reconstructed.financialIndependenceTarget,
        original.financialIndependenceTarget,
      );
    });

    test(
      'round-trips complete aggregate fields, order, and mixed currencies',
      () {
        final Portfolio original = portfolio(
          assets: <Asset>[
            asset(id: 'asset-1', currencyCode: 'MYR'),
            asset(id: 'asset-2', currencyCode: 'EUR', type: AssetType.etf),
          ],
          liabilities: <Liability>[
            liability(id: 'liability-1', currencyCode: 'USD'),
            liability(
              id: 'liability-2',
              currencyCode: 'JPY',
              type: LiabilityType.mortgage,
            ),
          ],
        );
        final Map<String, Object?> map = mapper.toMap(original);
        final Portfolio reconstructed = mapper.fromMap(map);

        expect(reconstructed.assets.map((Asset value) => value.id), <String>[
          'asset-1',
          'asset-2',
        ]);
        expect(
          reconstructed.liabilities.map((Liability value) => value.id),
          <String>['liability-1', 'liability-2'],
        );
        for (int index = 0; index < original.assets.length; index++) {
          final Asset expected = original.assets[index];
          final Asset actual = reconstructed.assets[index];
          expect(actual.id, expected.id);
          expect(actual.name, expected.name);
          expect(actual.type, expected.type);
          expect(actual.quantity.value, expected.quantity.value);
          expect(actual.unitPrice.amount, expected.unitPrice.amount);
          expect(
            actual.unitPrice.currencyCode,
            expected.unitPrice.currencyCode,
          );
          expect(actual.createdAt, expected.createdAt);
          expect(actual.updatedAt, expected.updatedAt);
          expect(actual.symbol, expected.symbol);
        }
        for (int index = 0; index < original.liabilities.length; index++) {
          final Liability expected = original.liabilities[index];
          final Liability actual = reconstructed.liabilities[index];
          expect(actual.id, expected.id);
          expect(actual.name, expected.name);
          expect(actual.type, expected.type);
          expect(
            actual.outstandingBalance.amount,
            expected.outstandingBalance.amount,
          );
          expect(actual.originalAmount.amount, expected.originalAmount.amount);
          expect(
            actual.outstandingBalance.currencyCode,
            expected.outstandingBalance.currencyCode,
          );
          expect(actual.createdAt, expected.createdAt);
          expect(actual.updatedAt, expected.updatedAt);
          expect(actual.lenderName, expected.lenderName);
          expect(actual.dueDate, expected.dueDate);
        }
        expect(original.assets.first.quantity.value, '1.23');
        expect(
          original.assets.first.unitPrice.amount,
          '999999999999999999999999.000000000000000001',
        );
        expect(
          original.liabilities.first.outstandingBalance.amount,
          '0.010000000000000001',
        );
      },
    );

    test('round-trips every supported enum using semantic names', () {
      for (final AssetType type in AssetType.values) {
        final Map<String, Object?> map = mapper.toMap(
          portfolio(assets: <Asset>[asset(type: type)]),
        );
        final List<Object?> assets = map['assets']! as List<Object?>;
        expect((assets.single as Map<String, Object?>)['type'], type.name);
        expect(mapper.fromMap(map).assets.single.type, type);
      }
      for (final LiabilityType type in LiabilityType.values) {
        final Map<String, Object?> map = mapper.toMap(
          portfolio(liabilities: <Liability>[liability(type: type)]),
        );
        final List<Object?> liabilities = map['liabilities']! as List<Object?>;
        expect((liabilities.single as Map<String, Object?>)['type'], type.name);
        expect(mapper.fromMap(map).liabilities.single.type, type);
      }
    });

    test('rejects malformed map data with field paths', () {
      final Map<String, Object?> unknownAssetType = mapper.toMap(
        portfolio(assets: <Asset>[asset()]),
      );
      final List<Object?> unknownAssetTypeAssets =
          unknownAssetType['assets']! as List<Object?>;
      (unknownAssetTypeAssets.single as Map<String, Object?>)['type'] =
          'unknown';

      final Map<String, Object?> unknownLiabilityType = mapper.toMap(
        portfolio(liabilities: <Liability>[liability()]),
      );
      final List<Object?> unknownLiabilityTypeItems =
          unknownLiabilityType['liabilities']! as List<Object?>;
      (unknownLiabilityTypeItems.single as Map<String, Object?>)['type'] =
          'unknown';

      final Map<String, Object?> invalidTimestamp = mapper.toMap(portfolio());
      invalidTimestamp['createdAt'] = 'not-a-timestamp';

      final Map<String, Object?> numericDecimal = mapper.toMap(
        portfolio(assets: <Asset>[asset()]),
      );
      final List<Object?> numericDecimalAssets =
          numericDecimal['assets']! as List<Object?>;
      (numericDecimalAssets.single as Map<String, Object?>)['quantity'] = 1;

      expect(
        () => mapper.fromMap(unknownAssetType),
        throwsA(mappingErrorAt('assets[0].type')),
      );
      expect(
        () => mapper.fromMap(unknownLiabilityType),
        throwsA(mappingErrorAt('liabilities[0].type')),
      );
      expect(
        () => mapper.fromMap(invalidTimestamp),
        throwsA(mappingErrorAt('createdAt')),
      );
      expect(
        () => mapper.fromMap(numericDecimal),
        throwsA(mappingErrorAt('assets[0].quantity')),
      );
    });

    test(
      'lets domain validation reject duplicate IDs and invalid timestamp order',
      () {
        final Map<String, Object?> duplicateAssets = mapper.toMap(
          portfolio(
            assets: <Asset>[
              asset(id: 'asset-1'),
              asset(id: 'asset-2'),
            ],
          ),
        );
        final List<Object?> duplicateItems =
            duplicateAssets['assets']! as List<Object?>;
        (duplicateItems[1] as Map<String, Object?>)['id'] = 'asset-1';

        final Map<String, Object?> invalidOrder = mapper.toMap(portfolio());
        invalidOrder['updatedAt'] = '2025-01-01T00:00:00.000Z';

        expect(
          () => mapper.fromMap(duplicateAssets),
          throwsA(mappingErrorAt('portfolio')),
        );
        expect(
          () => mapper.fromMap(invalidOrder),
          throwsA(mappingErrorAt('portfolio')),
        );
      },
    );

    test(
      'does not mutate the original aggregate or generate identity data',
      () {
        final Portfolio original = portfolio(assets: <Asset>[asset()]);
        final String originalId = original.id;
        final DateTime originalUpdatedAt = original.updatedAt;

        final Portfolio reconstructed = mapper.toDomain(mapper.toDto(original));

        expect(original.id, originalId);
        expect(original.updatedAt, originalUpdatedAt);
        expect(reconstructed.id, originalId);
        expect(reconstructed.updatedAt, originalUpdatedAt);
        expect(identical(original, reconstructed), isFalse);
      },
    );
  });
}
