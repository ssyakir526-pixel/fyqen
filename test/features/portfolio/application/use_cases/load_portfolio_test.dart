import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/application/use_cases/load_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  test('forwards IDs unchanged and returns the repository reference', () async {
    final Portfolio portfolio = Portfolio(
      id: 'portfolio-1',
      name: 'Main',
      assets: const [],
      liabilities: const [],
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final _RecordingRepository repository = _RecordingRepository(
      result: portfolio,
    );
    final LoadPortfolioUseCase useCase = LoadPortfolioUseCase(repository);

    final Portfolio? loaded = await useCase(' portfolio-1 ');

    expect(repository.receivedFindId, ' portfolio-1 ');
    expect(identical(loaded, portfolio), isTrue);
    expect(
      await LoadPortfolioUseCase(_RecordingRepository())('missing'),
      isNull,
    );
  });

  test('propagates repository exceptions unchanged', () async {
    final ArgumentError error = ArgumentError('load failed');
    final LoadPortfolioUseCase useCase = LoadPortfolioUseCase(
      _RecordingRepository(error: error),
    );

    await expectLater(useCase('portfolio-1'), throwsA(same(error)));
  });
}

class _RecordingRepository implements PortfolioRepository {
  _RecordingRepository({this.result, this.error});

  final Portfolio? result;
  final Object? error;
  String? receivedFindId;

  @override
  Future<Portfolio?> findById(String portfolioId) {
    receivedFindId = portfolioId;
    return error == null
        ? Future<Portfolio?>.value(result)
        : Future<Portfolio?>.error(error!);
  }

  @override
  Future<void> save(Portfolio portfolio) => Future<void>.value();

  @override
  Future<void> deleteById(String portfolioId) => Future<void>.value();
}
