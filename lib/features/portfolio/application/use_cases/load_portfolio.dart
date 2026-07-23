import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Loads a Portfolio through the application-owned repository contract.
final class LoadPortfolioUseCase {
  const LoadPortfolioUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<Portfolio?> call(String portfolioId) {
    return _repository.findById(portfolioId);
  }
}
