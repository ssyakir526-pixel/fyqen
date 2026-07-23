import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Saves a complete Portfolio through the application-owned repository contract.
final class SavePortfolioUseCase {
  const SavePortfolioUseCase(this._repository);

  final PortfolioRepository _repository;

  Future<void> call(Portfolio portfolio) {
    return _repository.save(portfolio);
  }
}
