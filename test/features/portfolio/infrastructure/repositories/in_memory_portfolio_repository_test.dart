import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/infrastructure/repositories/in_memory_portfolio_repository.dart';

void main() {
  Asset createAsset(String id, String currencyCode) => Asset(
    id: id,
    name: id,
    type: AssetType.stock,
    quantity: AssetQuantity('1'),
    unitPrice: AssetUnitPrice(amount: '1', currencyCode: currencyCode),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  Liability createLiability(String id, String currencyCode) => Liability(
    id: id,
    name: id,
    type: LiabilityType.personalLoan,
    outstandingBalance: LiabilityAmount(
      amount: '1',
      currencyCode: currencyCode,
    ),
    originalAmount: LiabilityAmount(amount: '1', currencyCode: currencyCode),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  Portfolio createPortfolio({
    String id = 'portfolio-1',
    String name = 'Main Portfolio',
    List<Asset> assets = const <Asset>[],
    List<Liability> liabilities = const <Liability>[],
  }) => Portfolio(
    id: id,
    name: name,
    assets: assets,
    liabilities: liabilities,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  group('InMemoryPortfolioRepository', () {
    test('implements the contract and starts empty per instance', () async {
      final InMemoryPortfolioRepository first = InMemoryPortfolioRepository();
      final InMemoryPortfolioRepository second = InMemoryPortfolioRepository();
      final Portfolio portfolio = createPortfolio();

      expect(first, isA<PortfolioRepository>());
      expect(await first.findById('portfolio-1'), isNull);
      await first.save(portfolio);
      expect(await second.findById('portfolio-1'), isNull);
    });

    test('finds exact references with trimmed case-sensitive IDs', () async {
      final InMemoryPortfolioRepository repository =
          InMemoryPortfolioRepository();
      final Portfolio portfolio = createPortfolio(
        assets: <Asset>[createAsset('asset-1', 'USD')],
        liabilities: <Liability>[createLiability('liability-1', 'MYR')],
      );

      await repository.save(portfolio);

      final Portfolio? found = await repository.findById(' portfolio-1 ');
      expect(identical(found, portfolio), isTrue);
      expect(await repository.findById('Portfolio-1'), isNull);
      expect(found!.assets, <Asset>[portfolio.assets.single]);
      expect(found.liabilities, <Liability>[portfolio.liabilities.single]);
      expect(() => found.assets.clear(), throwsUnsupportedError);
      await expectLater(repository.findById(''), throwsArgumentError);
      await expectLater(repository.findById('   '), throwsArgumentError);
    });

    test('saves new IDs and replaces existing IDs without merging', () async {
      final InMemoryPortfolioRepository repository =
          InMemoryPortfolioRepository();
      final Portfolio first = createPortfolio(
        assets: <Asset>[createAsset('asset-1', 'MYR')],
      );
      final Portfolio replacement = createPortfolio(
        name: 'Replacement',
        liabilities: <Liability>[createLiability('liability-1', 'USD')],
      );
      final Portfolio unrelated = createPortfolio(id: 'portfolio-2');

      await repository.save(first);
      await repository.save(unrelated);
      await repository.save(replacement);

      final Portfolio? stored = await repository.findById('portfolio-1');
      expect(identical(stored, replacement), isTrue);
      expect(stored!.assets, isEmpty);
      expect(stored.liabilities, <Liability>[replacement.liabilities.single]);
      expect(
        identical(await repository.findById('portfolio-2'), unrelated),
        isTrue,
      );
    });

    test('deletes by trimmed ID and treats absence as idempotent', () async {
      final InMemoryPortfolioRepository repository =
          InMemoryPortfolioRepository();
      final Portfolio first = createPortfolio();
      final Portfolio unrelated = createPortfolio(id: 'portfolio-2');

      await repository.save(first);
      await repository.save(unrelated);
      await repository.deleteById(' portfolio-1 ');

      expect(await repository.findById('portfolio-1'), isNull);
      expect(
        identical(await repository.findById('portfolio-2'), unrelated),
        isTrue,
      );
      await repository.deleteById('portfolio-1');
      await expectLater(repository.deleteById(''), throwsArgumentError);
      await expectLater(repository.deleteById('   '), throwsArgumentError);
      expect(first.id, 'portfolio-1');
    });
  });
}
