import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/portfolio/application/errors/portfolio_persistence_exception.dart';

void main() {
  test('preserves a stable persistence failure code and safe message', () {
    const PortfolioPersistenceException exception =
        PortfolioPersistenceException(
          code: PortfolioPersistenceFailureCode.unauthenticated,
          message: 'An authenticated user is required to access a portfolio.',
        );

    expect(exception.code, PortfolioPersistenceFailureCode.unauthenticated);
    expect(
      exception.message,
      'An authenticated user is required to access a portfolio.',
    );
  });
}
