import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';

/// An immutable aggregate root for a validated portfolio snapshot.
final class Portfolio {
  const Portfolio._({
    required String id,
    required String name,
    required List<Asset> assets,
    required List<Liability> liabilities,
    required FinancialIndependenceTarget? financialIndependenceTarget,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : _id = id,
       _name = name,
       _assets = assets,
       _liabilities = liabilities,
       _financialIndependenceTarget = financialIndependenceTarget,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory Portfolio({
    required String id,
    required String name,
    required List<Asset> assets,
    required List<Liability> liabilities,
    FinancialIndependenceTarget? financialIndependenceTarget,
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
      financialIndependenceTarget: financialIndependenceTarget,
      createdAt: normalizedCreatedAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  final String _id;
  final String _name;
  final List<Asset> _assets;
  final List<Liability> _liabilities;
  final FinancialIndependenceTarget? _financialIndependenceTarget;
  final DateTime _createdAt;
  final DateTime _updatedAt;

  String get id => _id;

  String get name => _name;

  List<Asset> get assets => _assets;

  List<Liability> get liabilities => _liabilities;

  FinancialIndependenceTarget? get financialIndependenceTarget =>
      _financialIndependenceTarget;

  DateTime get createdAt => _createdAt;

  DateTime get updatedAt => _updatedAt;

  /// Returns a new snapshot with the supplied name.
  Portfolio rename({required String name, required DateTime updatedAt}) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );

    return Portfolio(
      id: _id,
      name: name,
      assets: _assets,
      liabilities: _liabilities,
      financialIndependenceTarget: _financialIndependenceTarget,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  /// Returns a new snapshot with an appended asset.
  Portfolio addAsset({required Asset asset, required DateTime updatedAt}) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );

    if (_assets.any((Asset existingAsset) => existingAsset.id == asset.id)) {
      throw ArgumentError('Duplicate asset ID: ${asset.id}');
    }

    return Portfolio(
      id: _id,
      name: _name,
      assets: <Asset>[..._assets, asset],
      liabilities: _liabilities,
      financialIndependenceTarget: _financialIndependenceTarget,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  /// Returns a new snapshot with the matching asset replaced in place.
  Portfolio replaceAsset({required Asset asset, required DateTime updatedAt}) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );
    final int assetIndex = _assets.indexWhere(
      (Asset existingAsset) => existingAsset.id == asset.id,
    );

    if (assetIndex == -1) {
      throw ArgumentError('Asset ID not found: ${asset.id}');
    }

    final List<Asset> updatedAssets = List<Asset>.of(_assets);
    updatedAssets[assetIndex] = asset;

    return Portfolio(
      id: _id,
      name: _name,
      assets: updatedAssets,
      liabilities: _liabilities,
      financialIndependenceTarget: _financialIndependenceTarget,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  /// Returns a new snapshot without the asset identified by [assetId].
  Portfolio removeAsset({
    required String assetId,
    required DateTime updatedAt,
  }) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );
    final String normalizedAssetId = _requireText(assetId, 'assetId');
    final int assetIndex = _assets.indexWhere(
      (Asset asset) => asset.id == normalizedAssetId,
    );

    if (assetIndex == -1) {
      throw ArgumentError('Asset ID not found: $normalizedAssetId');
    }

    final List<Asset> updatedAssets = List<Asset>.of(_assets)
      ..removeAt(assetIndex);

    return Portfolio(
      id: _id,
      name: _name,
      assets: updatedAssets,
      liabilities: _liabilities,
      financialIndependenceTarget: _financialIndependenceTarget,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  /// Returns a new snapshot with an appended liability.
  Portfolio addLiability({
    required Liability liability,
    required DateTime updatedAt,
  }) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );

    if (_liabilities.any(
      (Liability existingLiability) => existingLiability.id == liability.id,
    )) {
      throw ArgumentError('Duplicate liability ID: ${liability.id}');
    }

    return Portfolio(
      id: _id,
      name: _name,
      assets: _assets,
      liabilities: <Liability>[..._liabilities, liability],
      financialIndependenceTarget: _financialIndependenceTarget,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  /// Returns a new snapshot with the matching liability replaced in place.
  Portfolio replaceLiability({
    required Liability liability,
    required DateTime updatedAt,
  }) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );
    final int liabilityIndex = _liabilities.indexWhere(
      (Liability existingLiability) => existingLiability.id == liability.id,
    );

    if (liabilityIndex == -1) {
      throw ArgumentError('Liability ID not found: ${liability.id}');
    }

    final List<Liability> updatedLiabilities = List<Liability>.of(_liabilities);
    updatedLiabilities[liabilityIndex] = liability;

    return Portfolio(
      id: _id,
      name: _name,
      assets: _assets,
      liabilities: updatedLiabilities,
      financialIndependenceTarget: _financialIndependenceTarget,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  /// Returns a new snapshot without the liability identified by [liabilityId].
  Portfolio removeLiability({
    required String liabilityId,
    required DateTime updatedAt,
  }) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );
    final String normalizedLiabilityId = _requireText(
      liabilityId,
      'liabilityId',
    );
    final int liabilityIndex = _liabilities.indexWhere(
      (Liability liability) => liability.id == normalizedLiabilityId,
    );

    if (liabilityIndex == -1) {
      throw ArgumentError('Liability ID not found: $normalizedLiabilityId');
    }

    final List<Liability> updatedLiabilities = List<Liability>.of(_liabilities)
      ..removeAt(liabilityIndex);

    return Portfolio(
      id: _id,
      name: _name,
      assets: _assets,
      liabilities: updatedLiabilities,
      financialIndependenceTarget: _financialIndependenceTarget,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  /// Returns a new snapshot with the supplied Financial Independence target.
  Portfolio setFinancialIndependenceTarget({
    required FinancialIndependenceTarget target,
    required DateTime updatedAt,
  }) {
    final DateTime normalizedUpdatedAt = _validatedModificationTimestamp(
      updatedAt,
    );

    return Portfolio(
      id: _id,
      name: _name,
      assets: _assets,
      liabilities: _liabilities,
      financialIndependenceTarget: target,
      createdAt: _createdAt,
      updatedAt: normalizedUpdatedAt,
    );
  }

  static String _requireText(String value, String name) {
    final String normalizedValue = value.trim();

    if (normalizedValue.isEmpty) {
      throw ArgumentError.value(value, name, 'must not be empty');
    }

    return normalizedValue;
  }

  DateTime _validatedModificationTimestamp(DateTime value) {
    final DateTime normalizedValue = value.toUtc();

    if (normalizedValue.isBefore(_updatedAt)) {
      throw ArgumentError.value(
        value,
        'updatedAt',
        'Modification timestamp must not be earlier than current updatedAt.',
      );
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
        other.runtimeType == runtimeType &&
            other is Portfolio &&
            other._id == _id;
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
