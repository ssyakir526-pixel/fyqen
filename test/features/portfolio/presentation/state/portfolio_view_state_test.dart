import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/presentation/state/portfolio_view_state.dart';

void main() {
  final Portfolio portfolio = Portfolio(
    id: 'primary',
    name: 'My Portfolio',
    assets: const <Asset>[],
    liabilities: const [],
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
  const PortfolioPersistenceException failure = PortfolioPersistenceException(
    code: PortfolioPersistenceFailureCode.unavailable,
    message: 'Safe infrastructure message.',
  );

  group('PortfolioViewState', () {
    test('initial and loading states have no Portfolio or failure', () {
      const PortfolioViewState initial = PortfolioViewState.initial();
      const PortfolioViewState loading = PortfolioViewState.loading();

      expect(initial.status, PortfolioStatus.initial);
      expect(initial.portfolio, isNull);
      expect(initial.failure, isNull);
      expect(loading.status, PortfolioStatus.loading);
      expect(loading.portfolio, isNull);
      expect(loading.failure, isNull);
    });

    test('ready and saving states preserve the supplied Portfolio reference', () {
      final PortfolioViewState ready = PortfolioViewState.ready(portfolio);
      final PortfolioViewState saving = PortfolioViewState.saving(portfolio);

      expect(identical(ready.portfolio, portfolio), isTrue);
      expect(ready.failure, isNull);
      expect(identical(saving.portfolio, portfolio), isTrue);
      expect(saving.failure, isNull);
    });

    test('failure may preserve the latest Portfolio', () {
      final PortfolioViewState loadFailure = PortfolioViewState.failure(
        failure: failure,
      );
      final PortfolioViewState saveFailure = PortfolioViewState.failure(
        portfolio: portfolio,
        failure: failure,
      );

      expect(loadFailure.portfolio, isNull);
      expect(loadFailure.failure, same(failure));
      expect(saveFailure.portfolio, same(portfolio));
      expect(saveFailure.failure, same(failure));
    });
  });
}
