import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/portfolio/application/repositories/portfolio_repository.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';

void main() {
  test('exposes the persistence-neutral Portfolio repository contract', () {
    void verifyContract(PortfolioRepository repository, Portfolio portfolio) {
      final Future<Portfolio?> foundPortfolio = repository.findById(
        portfolio.id,
      );
      final Future<void> savedPortfolio = repository.save(portfolio);
      final Future<void> deletedPortfolio = repository.deleteById(portfolio.id);

      expect(foundPortfolio, isA<Future<Portfolio?>>());
      expect(savedPortfolio, isA<Future<void>>());
      expect(deletedPortfolio, isA<Future<void>>());
    }

    expect(verifyContract, isA<Function>());
  });
}
