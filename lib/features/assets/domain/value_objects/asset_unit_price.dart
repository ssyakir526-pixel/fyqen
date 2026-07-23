import 'decimal_string_normalizer.dart';

/// Represents the exact non-negative price of one asset unit.
class AssetUnitPrice {
  const AssetUnitPrice._({required String amount, required String currencyCode})
    : _amount = amount,
      _currencyCode = currencyCode;

  factory AssetUnitPrice({
    required String amount,
    required String currencyCode,
  }) {
    final String normalizedAmount = DecimalStringNormalizer.normalize(
      amount,
      allowZero: true,
    );

    final String normalizedCurrencyCode = _normalizeCurrencyCode(currencyCode);

    return AssetUnitPrice._(
      amount: normalizedAmount,
      currencyCode: normalizedCurrencyCode,
    );
  }

  final String _amount;
  final String _currencyCode;

  String get amount => _amount;

  String get currencyCode => _currencyCode;

  static String _normalizeCurrencyCode(String value) {
    final String normalizedValue = value.trim().toUpperCase();

    final RegExp currencyCodePattern = RegExp(r'^[A-Z]{3}$');

    if (!currencyCodePattern.hasMatch(normalizedValue)) {
      throw FormatException(
        'Currency code must contain exactly three ASCII letters.',
        value,
      );
    }

    return normalizedValue;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is AssetUnitPrice &&
            other._amount == _amount &&
            other._currencyCode == _currencyCode;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _amount, _currencyCode);

  @override
  String toString() => '$_currencyCode $_amount';
}
