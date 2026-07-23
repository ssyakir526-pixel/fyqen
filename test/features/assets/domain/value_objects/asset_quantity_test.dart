import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';

void main() {
  group('AssetQuantity', () {
    test('accepts and canonicalizes positive decimal values', () {
      expect(AssetQuantity('12').value, '12');
      expect(AssetQuantity('3.5').value, '3.5');
      expect(AssetQuantity('  001.5000  ').value, '1.5');
      expect(AssetQuantity('0000.0001000').value, '0.0001');
      expect(
        AssetQuantity('0.123456789012345678901').value,
        '0.123456789012345678901',
      );
    });

    test('uses canonical values for equality, hash codes, and strings', () {
      final AssetQuantity first = AssetQuantity('1.5000');
      final AssetQuantity second = AssetQuantity('01.5');

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.toString(), '1.5');
    });

    test('rejects zero and negative values', () {
      expect(() => AssetQuantity('0'), throwsArgumentError);
      expect(() => AssetQuantity('0.0'), throwsArgumentError);
      expect(() => AssetQuantity('000.000'), throwsArgumentError);
      expect(() => AssetQuantity('-1.5'), throwsArgumentError);
    });

    test('rejects malformed decimal syntax', () {
      for (final String value in <String>[
        '',
        '   ',
        '+1',
        '1e3',
        '1,000',
        '1 0',
        'asset',
        '1.2.3',
        '1.',
        '.5',
      ]) {
        expect(() => AssetQuantity(value), throwsFormatException);
      }
    });
  });
}
