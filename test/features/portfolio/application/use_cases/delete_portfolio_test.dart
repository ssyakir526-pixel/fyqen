import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/application/use_cases/delete_portfolio.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  test('forwards IDs unchanged to repository deletion', () async {
    final _RecordingRepository repository = _RecordingRepository();

    await DeletePortfolioUseCase(repository)(' portfolio-1 ');

    expect(repository.receivedDeleteId, ' portfolio-1 ');
  });

  test('propagates repository exceptions unchanged', () async {
    final ArgumentError error = ArgumentError('delete failed');
    final DeletePortfolioUseCase useCase = DeletePortfolioUseCase(
      _RecordingRepository(error: error),
    );

    await expectLater(useCase('portfolio-1'), throwsA(same(error)));
  });
}

class _RecordingRepository implements PortfolioRepository {
  _RecordingRepository({this.error});

  final Object? error;
  String? receivedDeleteId;

  @override
  Future<Portfolio?> findById(String portfolioId) => Future<Portfolio?>.value();

  @override
  Future<void> save(Portfolio portfolio) => Future<void>.value();

  @override
  Future<void> deleteById(String portfolioId) {
    receivedDeleteId = portfolioId;
    return error == null ? Future<void>.value() : Future<void>.error(error!);
  }
}
