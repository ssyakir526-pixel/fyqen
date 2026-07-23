import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/application/use_cases/save_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  Portfolio createPortfolio() => Portfolio(
    id: 'portfolio-1',
    name: 'Main',
    assets: const [],
    liabilities: const [],
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('forwards the exact Portfolio reference to the repository', () async {
    final Portfolio portfolio = createPortfolio();
    final _RecordingRepository repository = _RecordingRepository();

    await SavePortfolioUseCase(repository)(portfolio);

    expect(identical(repository.savedPortfolio, portfolio), isTrue);
  });

  test('propagates repository exceptions unchanged', () async {
    final ArgumentError error = ArgumentError('save failed');
    final SavePortfolioUseCase useCase = SavePortfolioUseCase(
      _RecordingRepository(error: error),
    );

    await expectLater(useCase(createPortfolio()), throwsA(same(error)));
  });
}

class _RecordingRepository implements PortfolioRepository {
  _RecordingRepository({this.error});

  final Object? error;
  Portfolio? savedPortfolio;

  @override
  Future<Portfolio?> findById(String portfolioId) => Future<Portfolio?>.value();

  @override
  Future<void> save(Portfolio portfolio) {
    savedPortfolio = portfolio;
    return error == null ? Future<void>.value() : Future<void>.error(error!);
  }

  @override
  Future<void> deleteById(String portfolioId) => Future<void>.value();
}
