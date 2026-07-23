import 'package:fyqen/core/domain/utils/decimal_string_normalizer.dart';

/// An immutable, exact financial-independence net-worth target.
final class FinancialIndependenceTarget {
  const FinancialIndependenceTarget._({
    required String amount,
    required String currencyCode,
  }) : _amount = amount,
       _currencyCode = currencyCode;

  factory FinancialIndependenceTarget({
    required String amount,
    required String currencyCode,
  }) {
    final String normalizedAmount = DecimalStringNormalizer.normalize(
      amount,
      allowZero: false,
    );
    final String normalizedCurrencyCode = currencyCode.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(normalizedCurrencyCode)) {
      throw FormatException(
        'Currency code must contain exactly three ASCII letters.',
        currencyCode,
      );
    }

    return FinancialIndependenceTarget._(
      amount: normalizedAmount,
      currencyCode: normalizedCurrencyCode,
    );
  }

  final String _amount;
  final String _currencyCode;

  String get amount => _amount;

  String get currencyCode => _currencyCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType &&
            other is FinancialIndependenceTarget &&
            other._amount == _amount &&
            other._currencyCode == _currencyCode;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _amount, _currencyCode);
}
