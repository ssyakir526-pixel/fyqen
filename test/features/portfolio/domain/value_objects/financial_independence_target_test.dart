import 'package:flutter_test/flutter_test.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

void main() {
  group('FinancialIndependenceTarget', () {
    test('normalizes valid exact amount and currency', () {
      final FinancialIndependenceTarget target = FinancialIndependenceTarget(
        amount: '001000.50',
        currencyCode: 'myr',
      );

      expect(target.amount, '1000.5');
      expect(target.currencyCode, 'MYR');
    });

    test(
      'rejects zero, negative, malformed values, and invalid currencies',
      () {
        expect(
          () => FinancialIndependenceTarget(amount: '0', currencyCode: 'MYR'),
          throwsArgumentError,
        );
        expect(
          () => FinancialIndependenceTarget(amount: '-1', currencyCode: 'MYR'),
          throwsArgumentError,
        );
        expect(
          () => FinancialIndependenceTarget(amount: 'one', currencyCode: 'MYR'),
          throwsFormatException,
        );
        expect(
          () => FinancialIndependenceTarget(amount: '1', currencyCode: 'MY'),
          throwsFormatException,
        );
      },
    );

    test('compares normalized values by amount and currency', () {
      expect(
        FinancialIndependenceTarget(amount: '1.0', currencyCode: 'MYR'),
        FinancialIndependenceTarget(amount: '1', currencyCode: 'myr'),
      );
    });
  });
}
