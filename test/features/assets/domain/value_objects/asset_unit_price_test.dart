import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';

void main() {
  group('AssetUnitPrice', () {
    test('accepts and canonicalizes non-negative amounts', () {
      expect(AssetUnitPrice(amount: '12', currencyCode: 'MYR').amount, '12');
      expect(
        AssetUnitPrice(amount: '001.5000', currencyCode: 'MYR').amount,
        '1.5',
      );
      expect(
        AssetUnitPrice(amount: '  0.0001000 ', currencyCode: 'MYR').amount,
        '0.0001',
      );
      expect(
        AssetUnitPrice(amount: '000.000', currencyCode: 'MYR').amount,
        '0',
      );
      expect(
        AssetUnitPrice(
          amount: '0.123456789012345678901',
          currencyCode: 'MYR',
        ).amount,
        '0.123456789012345678901',
      );
    });

    test('normalizes valid currency codes', () {
      final AssetUnitPrice price = AssetUnitPrice(
        amount: '1',
        currencyCode: ' myr ',
      );

      expect(price.currencyCode, 'MYR');
    });

    test('rejects negative and malformed amount values', () {
      expect(
        () => AssetUnitPrice(amount: '-1', currencyCode: 'MYR'),
        throwsArgumentError,
      );

      for (final String value in <String>[
        '',
        '   ',
        '+1',
        '1e3',
        '1,000',
        '1 0',
        'price',
        '1.2.3',
        '1.',
        '.5',
      ]) {
        expect(
          () => AssetUnitPrice(amount: value, currencyCode: 'MYR'),
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
          () => AssetUnitPrice(amount: '1', currencyCode: value),
          throwsFormatException,
        );
      }
    });

    test('uses canonical amount and currency for equality and strings', () {
      final AssetUnitPrice first = AssetUnitPrice(
        amount: '01.500',
        currencyCode: 'myr',
      );
      final AssetUnitPrice second = AssetUnitPrice(
        amount: '1.5',
        currencyCode: 'MYR',
      );
      final AssetUnitPrice differentAmount = AssetUnitPrice(
        amount: '2',
        currencyCode: 'MYR',
      );
      final AssetUnitPrice differentCurrency = AssetUnitPrice(
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
