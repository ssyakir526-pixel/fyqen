import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';
import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_asset_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/add_liability_to_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/load_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_asset_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/remove_liability_from_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/rename_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_asset_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/replace_liability_in_portfolio.dart';
import 'package:fyqen/features/portfolio/application/use_cases/save_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/controllers/portfolio_controller.dart';
import 'package:fyqen/features/portfolio/presentation/state/portfolio_view_state.dart';

void main() {
  Portfolio portfolio({String name = 'Main Portfolio'}) {
    return Portfolio(
      id: 'primary',
      name: name,
      assets: const <Asset>[],
      liabilities: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  PortfolioController controller(_RecordingPortfolioRepository repository) {
    return PortfolioController(
      loadPortfolio: LoadPortfolioUseCase(repository),
      savePortfolio: SavePortfolioUseCase(repository),
      renamePortfolio: const RenamePortfolioUseCase(),
      addAssetToPortfolio: const AddAssetToPortfolioUseCase(),
      replaceAssetInPortfolio: const ReplaceAssetInPortfolioUseCase(),
      removeAssetFromPortfolio: const RemoveAssetFromPortfolioUseCase(),
      addLiabilityToPortfolio: const AddLiabilityToPortfolioUseCase(),
      replaceLiabilityInPortfolio: const ReplaceLiabilityInPortfolioUseCase(),
      removeLiabilityFromPortfolio: const RemoveLiabilityFromPortfolioUseCase(),
      currentTime: () => DateTime.utc(2026),
    );
  }

  group('PortfolioController', () {
    test('loads an existing Portfolio into the ready state', () async {
      final Portfolio existing = portfolio();
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository(portfolio: existing);
      final PortfolioController subject = controller(repository);

      await subject.load();

      expect(repository.findCalls, 1);
      expect(repository.findId, 'primary');
      expect(subject.state.status, PortfolioStatus.ready);
      expect(identical(subject.state.portfolio, existing), isTrue);
      expect(subject.state.failure, isNull);
    });

    test('creates and saves one deterministic empty Portfolio when missing', () async {
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository();
      final PortfolioController subject = controller(repository);

      await subject.load();

      final Portfolio saved = repository.savedPortfolio!;
      expect(repository.findCalls, 1);
      expect(repository.saveCalls, 1);
      expect(saved.id, 'primary');
      expect(saved.name, 'My Portfolio');
      expect(saved.assets, isEmpty);
      expect(saved.liabilities, isEmpty);
      expect(subject.state.status, PortfolioStatus.ready);
      expect(subject.state.portfolio, same(saved));
    });

    test('preserves the loaded Portfolio when a mutation save fails', () async {
      final Portfolio existing = portfolio();
      const PortfolioPersistenceException failure =
          PortfolioPersistenceException(
            code: PortfolioPersistenceFailureCode.unavailable,
            message: 'Safe infrastructure message.',
          );
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository(portfolio: existing, saveError: failure);
      final PortfolioController subject = controller(repository);
      await subject.load();

      final bool didSave = await subject.renamePortfolio('Renamed');

      expect(didSave, isFalse);
      expect(repository.saveCalls, 1);
      expect(subject.state.status, PortfolioStatus.failure);
      expect(subject.state.portfolio, same(existing));
      expect(subject.state.failure, same(failure));
    });

    test('retries an explicit failed load without automatic retries', () async {
      const PortfolioPersistenceException failure =
          PortfolioPersistenceException(
            code: PortfolioPersistenceFailureCode.unavailable,
            message: 'Safe infrastructure message.',
          );
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository(findError: failure);
      final PortfolioController subject = controller(repository);

      await subject.load();
      expect(subject.state.status, PortfolioStatus.failure);
      expect(repository.findCalls, 1);

      repository.findError = null;
      repository.portfolio = portfolio();
      await subject.retryLoad();

      expect(repository.findCalls, 2);
      expect(subject.state.status, PortfolioStatus.ready);
    });

    test('prevents duplicate loads and ignores a late completion after dispose', () async {
      final Completer<Portfolio?> pendingLoad = Completer<Portfolio?>();
      final _RecordingPortfolioRepository repository =
          _RecordingPortfolioRepository(findFuture: pendingLoad.future);
      final PortfolioController subject = controller(repository);

      final Future<void> firstLoad = subject.load();
      final Future<void> duplicateLoad = subject.load();
      expect(repository.findCalls, 1);

      subject.dispose();
      pendingLoad.complete(portfolio());
      await firstLoad;
      await duplicateLoad;

      expect(subject.state.status, PortfolioStatus.loading);
    });
  });
}

final class _RecordingPortfolioRepository implements PortfolioRepository {
  _RecordingPortfolioRepository({
    this.portfolio,
    this.findError,
    this.saveError,
    this.findFuture,
  });

  Portfolio? portfolio;
  Object? findError;
  Object? saveError;
  Future<Portfolio?>? findFuture;
  int findCalls = 0;
  int saveCalls = 0;
  String? findId;
  Portfolio? savedPortfolio;

  @override
  Future<Portfolio?> findById(String portfolioId) {
    findCalls += 1;
    findId = portfolioId;
    if (findFuture != null) {
      return findFuture!;
    }
    return findError == null
        ? Future<Portfolio?>.value(portfolio)
        : Future<Portfolio?>.error(findError!);
  }

  @override
  Future<void> save(Portfolio value) {
    saveCalls += 1;
    savedPortfolio = value;
    return saveError == null
        ? Future<void>.value()
        : Future<void>.error(saveError!);
  }

  @override
  Future<void> deleteById(String portfolioId) => Future<void>.value();
}
