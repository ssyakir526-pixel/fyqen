import 'decimal_string_normalizer.dart';

/// A positive asset quantity stored as an exact canonical decimal string.
final class AssetQuantity {
  const AssetQuantity._(this._value);

  factory AssetQuantity(String value) {
    return AssetQuantity._(
      DecimalStringNormalizer.normalize(value, allowZero: false),
    );
  }

  final String _value;

  String get value => _value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType &&
        other is AssetQuantity &&
        other._value == _value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _value);

  @override
  String toString() => _value;
}
