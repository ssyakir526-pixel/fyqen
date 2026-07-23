import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';

/// An immutable aggregate root for a validated portfolio snapshot.
final class Portfolio {
  const Portfolio._({
    required String id,
    required String name,
    required List<Asset> assets,
    required List<Liability> liabilities,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : _id = id,
       _name = name,
       _assets = assets,
       _liabilities = liabilities,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory Portfolio({
    required String id,
    required String name,
    required List<Asset> assets,
    required List<Liability> liabilities,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final String normalizedId = _requireText(id, 'id');
    final String normalizedName = _requireText(name, 'name');
    final DateTime normalizedCreatedAt = createdAt.toUtc();
    final DateTime normalizedUpdatedAt = updatedAt.toUtc();

    if (normalizedUpdatedAt.isBefore(normalizedCreatedAt)) {
      throw ArgumentError.value(
        updatedAt,
        'updatedAt',
        'Updated timestamp must not be earlier than created timestamp.',
      );
    }

    _validateAssetIds(assets);
    _validateLiabilityIds(liabilities);

    return Portfolio._(
      id: normalizedId,
      name: normalizedName,
      assets: List<Asset>.unmodifiable(assets),
      liabilities: List<Liability>.unmodifiable(liabilities),
      createdAt: normalizedCreatedAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  final String _id;
  final String _name;
  final List<Asset> _assets;
  final List<Liability> _liabilities;
  final DateTime _createdAt;
  final DateTime _updatedAt;

  String get id => _id;

  String get name => _name;

  List<Asset> get assets => _assets;

  List<Liability> get liabilities => _liabilities;

  DateTime get createdAt => _createdAt;

  DateTime get updatedAt => _updatedAt;

  static String _requireText(String value, String name) {
    final String normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, name, 'must not be empty');
    }

    return normalizedValue;
  }

  static void _validateAssetIds(List<Asset> assets) {
    final Set<String> assetIds = <String>{};

    for (final Asset asset in assets) {
      if (!assetIds.add(asset.id)) {
        throw ArgumentError('Duplicate asset ID: ${asset.id}');
      }
    }
  }

  static void _validateLiabilityIds(List<Liability> liabilities) {
    final Set<String> liabilityIds = <String>{};

    for (final Liability liability in liabilities) {
      if (!liabilityIds.add(liability.id)) {
        throw ArgumentError('Duplicate liability ID: ${liability.id}');
      }
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other.runtimeType == runtimeType && other is Portfolio && other._id == _id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _id);

  @override
  String toString() {
    return 'Portfolio('
        'id: $_id, '
        'name: $_name, '
        'assetCount: ${_assets.length}, '
        'liabilityCount: ${_liabilities.length}'
        ')';
  }
}
