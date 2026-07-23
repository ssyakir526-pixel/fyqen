import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';

void main() {
  group('LiabilityAmount', () {
    test('accepts and canonicalizes non-negative decimal amounts', () {
      expect(LiabilityAmount(amount: '12', currencyCode: 'MYR').amount, '12');
      expect(
        LiabilityAmount(amount: '001.5000', currencyCode: 'MYR').amount,
        '1.5',
      );
      expect(
        LiabilityAmount(amount: '  0.0001000 ', currencyCode: 'MYR').amount,
        '0.0001',
      );
      expect(
        LiabilityAmount(amount: '000.000', currencyCode: 'MYR').amount,
        '0',
      );
      expect(
        LiabilityAmount(
          amount: '0.123456789012345678901',
          currencyCode: 'MYR',
        ).amount,
        '0.123456789012345678901',
      );
    });

    test('normalizes valid currency codes', () {
      final LiabilityAmount amount = LiabilityAmount(
        amount: '1',
        currencyCode: ' myr ',
      );

      expect(amount.currencyCode, 'MYR');
    });

    test('rejects malformed and negative amount values', () {
      expect(
        () => LiabilityAmount(amount: '-1', currencyCode: 'MYR'),
        throwsArgumentError,
      );

      for (final String value in <String>[
        '',
        '   ',
        '+1',
        '1e3',
        '1,000',
        '1 0',
        'amount',
        '1.2.3',
        '1.',
        '.5',
      ]) {
        expect(
          () => LiabilityAmount(amount: value, currencyCode: 'MYR'),
          throwsFormatException,
        );
      }
    });

    test('rejects malformed currency codes', () {
      for (final String value in <String>[
        '',
        '   ',
        'RM',
        'USDT',
        '12A',
        'U\$D',
        'MY R',
      ]) {
        expect(
          () => LiabilityAmount(amount: '1', currencyCode: value),
          throwsFormatException,
        );
      }
    });

    test('uses canonical amount and currency for equality and strings', () {
      final LiabilityAmount first = LiabilityAmount(
        amount: '01.500',
        currencyCode: 'myr',
      );
      final LiabilityAmount second = LiabilityAmount(
        amount: '1.5',
        currencyCode: 'MYR',
      );
      final LiabilityAmount differentAmount = LiabilityAmount(
        amount: '2',
        currencyCode: 'MYR',
      );
      final LiabilityAmount differentCurrency = LiabilityAmount(
        amount: '1.5',
        currencyCode: 'USD',
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, isNot(differentAmount));
      expect(first, isNot(differentCurrency));
      expect(first.toString(), 'MYR 1.5');
    });
  });
}
