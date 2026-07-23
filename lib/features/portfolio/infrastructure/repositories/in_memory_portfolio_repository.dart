import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

/// A non-durable Portfolio repository implementation for development and tests.
final class InMemoryPortfolioRepository implements PortfolioRepository {
  final Map<String, Portfolio> _portfolios = <String, Portfolio>{};

  @override
  Future<Portfolio?> findById(String portfolioId) async {
    return _portfolios[_normalizeLookupId(portfolioId)];
  }

  @override
  Future<void> save(Portfolio portfolio) async {
    _portfolios[portfolio.id] = portfolio;
  }

  @override
  Future<void> deleteById(String portfolioId) async {
    _portfolios.remove(_normalizeLookupId(portfolioId));
  }

  String _normalizeLookupId(String value) {
    final String normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(
        value,
        'portfolioId',
        'Portfolio ID must not be empty.',
      );
    }

    return normalizedValue;
  }
}
