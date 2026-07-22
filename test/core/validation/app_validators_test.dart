import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/core/validation/app_validators.dart';

void main() {
  group('requiredField', () {
    test('rejects missing values and accepts valid text', () {
      expect(AppValidators.requiredField(null), 'This field is required.');
      expect(AppValidators.requiredField(''), 'This field is required.');
      expect(AppValidators.requiredField('   '), 'This field is required.');
      expect(AppValidators.requiredField('Fyqen'), isNull);
      expect(
        AppValidators.requiredField(null, message: 'Required.'),
        'Required.',
      );
    });
  });

  group('email', () {
    test('validates common email formats', () {
      expect(AppValidators.email(null), 'Email is required.');
      expect(AppValidators.email(''), 'Email is required.');
      expect(AppValidators.email('invalid'), 'Enter a valid email address.');
      expect(
        AppValidators.email('name@example'),
        'Enter a valid email address.',
      );
      expect(AppValidators.email('name@example.com'), isNull);
      expect(AppValidators.email('name@mail.example.com'), isNull);
    });
  });

  group('minimumLength', () {
    test('validates minimum character requirements', () {
      expect(
        AppValidators.minimumLength(null, minimum: 4),
        'This field is required.',
      );
      expect(
        AppValidators.minimumLength('', minimum: 4),
        'This field is required.',
      );
      expect(
        AppValidators.minimumLength('abc', minimum: 4),
        'Use at least 4 characters.',
      );
      expect(AppValidators.minimumLength('abcd', minimum: 4), isNull);
      expect(AppValidators.minimumLength('abcde', minimum: 4), isNull);
      expect(
        AppValidators.minimumLength('a', minimum: 4, message: 'Too short.'),
        'Too short.',
      );
    });
  });
}
