import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/app/app_composition_root.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_asset_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_liability_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/delete_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/load_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_asset_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_liability_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/rename_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_asset_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_liability_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/save_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/infrastructure/repositories/in_memory_portfolio_repository.dart';

void main() {
  Portfolio createPortfolio({String id = 'portfolio-1'}) {
    return Portfolio(
      id: id,
      name: 'Main Portfolio',
      assets: const <Asset>[],
      liabilities: const <Liability>[],
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  group('AppCompositionRoot', () {
    test('creates the default graph with all Portfolio use cases', () {
      final AppCompositionRoot root = AppCompositionRoot();

      expect(root.portfolioRepository, isA<InMemoryPortfolioRepository>());
      expect(root.portfolioRepository, isA<PortfolioRepository>());
      expect(root.loadPortfolio, isA<LoadPortfolioUseCase>());
      expect(root.savePortfolio, isA<SavePortfolioUseCase>());
      expect(root.deletePortfolio, isA<DeletePortfolioUseCase>());
      expect(root.renamePortfolio, isA<RenamePortfolioUseCase>());
      expect(root.addAssetToPortfolio, isA<AddAssetToPortfolioUseCase>());
      expect(root.replaceAssetInPortfolio, isA<ReplaceAssetInPortfolioUseCase>());
      expect(root.removeAssetFromPortfolio, isA<RemoveAssetFromPortfolioUseCase>());
      expect(
        root.addLiabilityToPortfolio,
        isA<AddLiabilityToPortfolioUseCase>(),
      );
      expect(
        root.replaceLiabilityInPortfolio,
        isA<ReplaceLiabilityInPortfolioUseCase>(),
      );
      expect(
        root.removeLiabilityFromPortfolio,
        isA<RemoveLiabilityFromPortfolioUseCase>(),
      );
    });

    test('uses a supplied repository without construction side effects', () async {
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository();
      final AppCompositionRoot root = AppCompositionRoot(
        portfolioRepository: repository,
      );
      final Portfolio portfolio = createPortfolio();

      expect(identical(root.portfolioRepository, repository), isTrue);
      expect(repository.findCalls, 0);
      expect(repository.saveCalls, 0);
      expect(repository.deleteCalls, 0);

      await root.savePortfolio(portfolio);
      final Portfolio? loaded = await root.loadPortfolio(' portfolio-1 ');
      await root.deletePortfolio('portfolio-1');

      expect(repository.saveCalls, 1);
      expect(identical(repository.savedPortfolio, portfolio), isTrue);
      expect(repository.findCalls, 1);
      expect(repository.findId, ' portfolio-1 ');
      expect(identical(loaded, portfolio), isTrue);
      expect(repository.deleteCalls, 1);
      expect(repository.deleteId, 'portfolio-1');
    });

    test('preserves repository exceptions through composed workflows', () async {
      final ArgumentError error = ArgumentError('save failed');
      final AppCompositionRoot root = AppCompositionRoot(
        portfolioRepository: _RecordingPortfolioRepository(saveError: error),
      );

      await expectLater(root.savePortfolio(createPortfolio()), throwsA(same(error)));
    });

    test('keeps aggregate operations synchronous and repository-free', () {
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository();
      final AppCompositionRoot root = AppCompositionRoot(
        portfolioRepository: repository,
      );
      final Portfolio original = createPortfolio();

      final Portfolio renamed = root.renamePortfolio(
        portfolio: original,
        name: 'Renamed Portfolio',
        updatedAt: DateTime.utc(2026, 1, 2),
      );

      expect(renamed.name, 'Renamed Portfolio');
      expect(identical(renamed, original), isFalse);
      expect(repository.findCalls, 0);
      expect(repository.saveCalls, 0);
      expect(repository.deleteCalls, 0);
    });

    test('shares default persistence within a root and isolates separate roots', () async {
      final AppCompositionRoot firstRoot = AppCompositionRoot();
      final AppCompositionRoot secondRoot = AppCompositionRoot();
      final Portfolio portfolio = createPortfolio();

      await firstRoot.savePortfolio(portfolio);

      expect(
        identical(firstRoot.portfolioRepository, secondRoot.portfolioRepository),
        isFalse,
      );
      expect(identical(await firstRoot.loadPortfolio('portfolio-1'), portfolio), isTrue);
      expect(await secondRoot.loadPortfolio('portfolio-1'), isNull);
    });
  });
}

final class _RecordingPortfolioRepository implements PortfolioRepository {
  _RecordingPortfolioRepository({this.saveError});

  final Object? saveError;
  int findCalls = 0;
  int saveCalls = 0;
  int deleteCalls = 0;
  String? findId;
  String? deleteId;
  Portfolio? savedPortfolio;

  @override
  Future<Portfolio?> findById(String portfolioId) {
    findCalls += 1;
    findId = portfolioId;
    return Future<Portfolio?>.value(savedPortfolio);
  }

  @override
  Future<void> save(Portfolio portfolio) {
    saveCalls += 1;
    savedPortfolio = portfolio;
    return saveError == null
        ? Future<void>.value()
        : Future<void>.error(saveError!);
  }

  @override
  Future<void> deleteById(String portfolioId) {
    deleteCalls += 1;
    deleteId = portfolioId;
    return Future<void>.value();
  }
}
