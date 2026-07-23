import '../enums/asset_type.dart';
import '../value_objects/asset_quantity.dart';
import '../value_objects/asset_unit_price.dart';

/// An immutable, persistence-independent financial asset entity.
class Asset {
  const Asset._({
    required String id,
    required String name,
    required AssetType type,
    required AssetQuantity quantity,
    required AssetUnitPrice unitPrice,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String? symbol,
  }) : _id = id,
       _name = name,
       _type = type,
       _quantity = quantity,
       _unitPrice = unitPrice,
       _createdAt = createdAt,
       _updatedAt = updatedAt,
       _symbol = symbol;

  factory Asset({
    required String id,
    required String name,
    required AssetType type,
    required AssetQuantity quantity,
    required AssetUnitPrice unitPrice,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? symbol,
  }) {
    final String normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Asset ID must not be empty.');
    }

    final String normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Asset name must not be empty.');
    }

    final String? normalizedSymbol = _normalizeSymbol(symbol);
    final DateTime normalizedCreatedAt = createdAt.toUtc();
    final DateTime normalizedUpdatedAt = updatedAt.toUtc();

    if (normalizedUpdatedAt.isBefore(normalizedCreatedAt)) {
      throw ArgumentError.value(
        updatedAt,
        'updatedAt',
        'Updated timestamp must not be earlier than created timestamp.',
      );
    }

    return Asset._(
      id: normalizedId,
      name: normalizedName,
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      createdAt: normalizedCreatedAt,
      updatedAt: normalizedUpdatedAt,
      symbol: normalizedSymbol,
    );
  }

  final String _id;
  final String _name;
  final AssetType _type;
  final AssetQuantity _quantity;
  final AssetUnitPrice _unitPrice;
  final DateTime _createdAt;
  final DateTime _updatedAt;
  final String? _symbol;

  String get id => _id;

  String get name => _name;

  AssetType get type => _type;

  AssetQuantity get quantity => _quantity;

  AssetUnitPrice get unitPrice => _unitPrice;

  DateTime get createdAt => _createdAt;

  DateTime get updatedAt => _updatedAt;

  String? get symbol => _symbol;

  static String? _normalizeSymbol(String? value) {
    if (value == null) {
      return null;
    }

    final String normalizedValue = value.trim();

    return normalizedValue.isEmpty ? null : normalizedValue;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType && other is Asset && other._id == _id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _id);

  @override
  String toString() {
    return 'Asset(id: $_id, name: $_name, type: $_type)';
  }
}
