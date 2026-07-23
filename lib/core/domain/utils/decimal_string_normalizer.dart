/// Validates and canonicalizes exact non-negative decimal strings.
abstract final class DecimalStringNormalizer {
  const DecimalStringNormalizer._();

  static final RegExp _decimalPattern = RegExp(r'^\d+(?:\.\d+)?$');
  static final RegExp _negativeDecimalPattern = RegExp(r'^-\d+(?:\.\d+)?$');
  static final RegExp _leadingZeroesPattern = RegExp(r'^0+');
  static final RegExp _trailingZeroesPattern = RegExp(r'0+$');

  static String normalize(String value, {required bool allowZero}) {
    final String trimmedValue = value.trim();

    if (_negativeDecimalPattern.hasMatch(trimmedValue)) {
      throw ArgumentError.value(value, 'value', 'must not be negative');
    }
    if (!_decimalPattern.hasMatch(trimmedValue)) {
      throw FormatException('Invalid decimal value: $value');
    }

    final List<String> parts = trimmedValue.split('.');
    final String normalizedInteger = _normalizeInteger(parts.first);
    final String normalizedFraction = parts.length == 2
        ? parts.last.replaceFirst(_trailingZeroesPattern, '')
        : '';
    final String normalizedValue = normalizedFraction.isEmpty
        ? normalizedInteger
        : '$normalizedInteger.$normalizedFraction';

    if (!allowZero && normalizedValue == '0') {
      throw ArgumentError.value(value, 'value', 'must be greater than zero');
    }

    return normalizedValue;
  }

  static String _normalizeInteger(String value) {
    final String withoutLeadingZeroes = value.replaceFirst(
      _leadingZeroesPattern,
      '',
    );

    return withoutLeadingZeroes.isEmpty ? '0' : withoutLeadingZeroes;
  }
}
