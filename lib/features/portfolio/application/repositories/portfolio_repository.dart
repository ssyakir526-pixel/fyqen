import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// Defines persistence capabilities required by future Portfolio workflows.
abstract interface class PortfolioRepository {
  Future<Portfolio?> findById(String portfolioId);

  Future<void> save(Portfolio portfolio);

  Future<void> deleteById(String portfolioId);
}
