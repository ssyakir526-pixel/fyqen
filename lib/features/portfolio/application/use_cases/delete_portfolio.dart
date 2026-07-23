import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';

/// Deletes a Portfolio through the application-owned repository contract.
final class DeletePortfolioUseCase {
  const DeletePortfolioUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<void> call(String portfolioId) {
    return _repository.deleteById(portfolioId);
  }
}
