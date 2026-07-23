import '../../../../core/domain/utils/decimal_string_normalizer.dart';

/// An exact non-negative liability amount in a normalized currency.
final class LiabilityAmount {
  const LiabilityAmount._({
    required String amount,
    required String currencyCode,
  }) : _amount = amount,
       _currencyCode = currencyCode;

  factory LiabilityAmount({
    required String amount,
    required String currencyCode,
  }) {
    return LiabilityAmount._(
      amount: DecimalStringNormalizer.normalize(amount, allowZero: true),
      currencyCode: _normalizeCurrencyCode(currencyCode),
    );
  }

  static final RegExp _currencyCodePattern = RegExp(r'^[A-Z]{3}$');

  final String _amount;
  final String _currencyCode;

  String get amount => _amount;

  String get currencyCode => _currencyCode;

  static String _normalizeCurrencyCode(String value) {
    final String normalizedValue = value.trim().toUpperCase();

    if (!_currencyCodePattern.hasMatch(normalizedValue)) {
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
            other is LiabilityAmount &&
            other._amount == _amount &&
            other._currencyCode == _currencyCode;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _amount, _currencyCode);

  @override
  String toString() => '$_currencyCode $_amount';
}
