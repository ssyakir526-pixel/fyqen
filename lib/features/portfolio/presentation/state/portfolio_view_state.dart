import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

enum PortfolioStatus { initial, loading, ready, saving, failure }

/// Immutable presentation state for one authenticated Portfolio session.
final class PortfolioViewState {
  const PortfolioViewState._({
    required this.status,
    required this.portfolio,
    required this.failure,
  });

  const PortfolioViewState.initial()
    : this._(
        status: PortfolioStatus.initial,
        portfolio: null,
        failure: null,
      );

  const PortfolioViewState.loading()
    : this._(
        status: PortfolioStatus.loading,
        portfolio: null,
        failure: null,
      );

  const PortfolioViewState.ready(Portfolio portfolio)
    : this._(
        status: PortfolioStatus.ready,
        portfolio: portfolio,
        failure: null,
      );

  const PortfolioViewState.saving(Portfolio portfolio)
    : this._(
        status: PortfolioStatus.saving,
        portfolio: portfolio,
        failure: null,
      );

  const PortfolioViewState.failure({
    Portfolio? portfolio,
    required PortfolioPersistenceException failure,
  }) : this._(
         status: PortfolioStatus.failure,
         portfolio: portfolio,
         failure: failure,
       );

  final PortfolioStatus status;
  final Portfolio? portfolio;
  final PortfolioPersistenceException? failure;
}
