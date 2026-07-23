import 'package:fyqen/features/assets/domain/entities/asset.dart';
import 'package:fyqen/features/assets/domain/enums/asset_type.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_quantity.dart';
import 'package:fyqen/features/assets/domain/value_objects/asset_unit_price.dart';
import 'package:fyqen/features/liabilities/domain/entities/liability.dart';
import 'package:fyqen/features/liabilities/domain/enums/liability_type.dart';
import 'package:fyqen/features/liabilities/domain/value_objects/liability_amount.dart';
import 'package:fyqen/features/portfolio/domain/entities/portfolio.dart';
import 'package:fyqen/features/portfolio/domain/value_objects/financial_independence_target.dart';
import 'package:fyqen/features/portfolio/infrastructure/dtos/portfolio_dto.dart';
import 'package:fyqen/features/portfolio/infrastructure/errors/portfolio_data_mapping_exception.dart';

/// Converts complete Portfolio aggregates to and from the version 1 schema.
final class PortfolioMapper {
  const PortfolioMapper();

  PortfolioDto toDto(Portfolio portfolio) {
    final FinancialIndependenceTarget? target =
        portfolio.financialIndependenceTarget;
    return PortfolioDto(
      schemaVersion: PortfolioDto.supportedSchemaVersion,
      id: portfolio.id,
      name: portfolio.name,
      createdAt: _timestampToString(portfolio.createdAt),
      updatedAt: _timestampToString(portfolio.updatedAt),
      assets: portfolio.assets.map(_assetToMap).toList(growable: false),
      liabilities: portfolio.liabilities
          .map(_liabilityToMap)
          .toList(growable: false),
      financialIndependenceTarget: target == null
          ? null
          : _financialIndependenceTargetToMap(target),
    );
  }

  Map<String, Object?> toMap(Portfolio portfolio) => toDto(portfolio).toMap();

  Portfolio fromMap(Map<String, Object?> map) =>
      toDomain(PortfolioDto.fromMap(map));

  Portfolio toDomain(PortfolioDto dto) {
    final List<Asset> assets = List<Asset>.generate(
      dto.assets.length,
      (int index) => _assetFromMap(dto.assets[index], 'assets[$index]'),
    );
    final List<Liability> liabilities = List<Liability>.generate(
      dto.liabilities.length,
      (int index) =>
          _liabilityFromMap(dto.liabilities[index], 'liabilities[$index]'),
    );
    final FinancialIndependenceTarget? financialIndependenceTarget =
        _financialIndependenceTargetFromMap(dto.financialIndependenceTarget);

    try {
      return Portfolio(
        id: dto.id,
        name: dto.name,
        assets: assets,
        liabilities: liabilities,
        financialIndependenceTarget: financialIndependenceTarget,
        createdAt: _timestampFromString(dto.createdAt, 'createdAt'),
        updatedAt: _timestampFromString(dto.updatedAt, 'updatedAt'),
      );
    } on ArgumentError catch (error) {
      throw PortfolioDataMappingException(
        path: 'portfolio',
        message: 'Portfolio data violates a domain invariant.',
        cause: error,
      );
    }
  }

  static Map<String, Object?> _assetToMap(Asset asset) {
    return <String, Object?>{
      'id': asset.id,
      'name': asset.name,
      'type': asset.type.name,
      'quantity': asset.quantity.value,
      'unitPrice': asset.unitPrice.amount,
      'currencyCode': asset.unitPrice.currencyCode,
      'createdAt': _timestampToString(asset.createdAt),
      'updatedAt': _timestampToString(asset.updatedAt),
      'symbol': asset.symbol,
    };
  }

  static Map<String, Object?> _liabilityToMap(Liability liability) {
    return <String, Object?>{
      'id': liability.id,
      'name': liability.name,
      'type': liability.type.name,
      'outstandingBalance': liability.outstandingBalance.amount,
      'originalAmount': liability.originalAmount.amount,
      'currencyCode': liability.outstandingBalance.currencyCode,
      'createdAt': _timestampToString(liability.createdAt),
      'updatedAt': _timestampToString(liability.updatedAt),
      'lenderName': liability.lenderName,
      'dueDate': liability.dueDate == null
          ? null
          : _timestampToString(liability.dueDate!),
    };
  }

  static Map<String, Object?> _financialIndependenceTargetToMap(
    FinancialIndependenceTarget target,
  ) {
    return <String, Object?>{
      'amount': target.amount,
      'currencyCode': target.currencyCode,
    };
  }

  static FinancialIndependenceTarget? _financialIndependenceTargetFromMap(
    Map<String, Object?>? map,
  ) {
    if (map == null) {
      return null;
    }

    try {
      return FinancialIndependenceTarget(
        amount: map['amount'] as String,
        currencyCode: map['currencyCode'] as String,
      );
    } on ArgumentError catch (error) {
      throw PortfolioDataMappingException(
        path: 'financialIndependenceTarget',
        message: 'Financial Independence target violates a domain invariant.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw PortfolioDataMappingException(
        path: 'financialIndependenceTarget',
        message: 'Financial Independence target has an invalid value.',
        cause: error,
      );
    }
  }

  static Asset _assetFromMap(Map<String, Object?> map, String path) {
    try {
      return Asset(
        id: map['id']! as String,
        name: map['name']! as String,
        type: _assetTypeFromName(map['type']! as String, '$path.type'),
        quantity: AssetQuantity(map['quantity']! as String),
        unitPrice: AssetUnitPrice(
          amount: map['unitPrice']! as String,
          currencyCode: map['currencyCode']! as String,
        ),
        createdAt: _timestampFromString(
          map['createdAt']! as String,
          '$path.createdAt',
        ),
        updatedAt: _timestampFromString(
          map['updatedAt']! as String,
          '$path.updatedAt',
        ),
        symbol: map['symbol'] as String?,
      );
    } on PortfolioDataMappingException {
      rethrow;
    } on ArgumentError catch (error) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Asset data violates a domain invariant.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Asset data has an invalid value.',
        cause: error,
      );
    }
  }

  static Liability _liabilityFromMap(Map<String, Object?> map, String path) {
    try {
      return Liability(
        id: map['id']! as String,
        name: map['name']! as String,
        type: _liabilityTypeFromName(map['type']! as String, '$path.type'),
        outstandingBalance: LiabilityAmount(
          amount: map['outstandingBalance']! as String,
          currencyCode: map['currencyCode']! as String,
        ),
        originalAmount: LiabilityAmount(
          amount: map['originalAmount']! as String,
          currencyCode: map['currencyCode']! as String,
        ),
        createdAt: _timestampFromString(
          map['createdAt']! as String,
          '$path.createdAt',
        ),
        updatedAt: _timestampFromString(
          map['updatedAt']! as String,
          '$path.updatedAt',
        ),
        lenderName: map['lenderName'] as String?,
        dueDate: _optionalTimestampFromString(
          map['dueDate'] as String?,
          '$path.dueDate',
        ),
      );
    } on PortfolioDataMappingException {
      rethrow;
    } on ArgumentError catch (error) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Liability data violates a domain invariant.',
        cause: error,
      );
    } on FormatException catch (error) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Liability data has an invalid value.',
        cause: error,
      );
    }
  }

  static AssetType _assetTypeFromName(String value, String path) {
    for (final AssetType type in AssetType.values) {
      if (type.name == value) {
        return type;
      }
    }
    throw PortfolioDataMappingException(
      path: path,
      message: 'Unsupported AssetType name: $value.',
    );
  }

  static LiabilityType _liabilityTypeFromName(String value, String path) {
    for (final LiabilityType type in LiabilityType.values) {
      if (type.name == value) {
        return type;
      }
    }
    throw PortfolioDataMappingException(
      path: path,
      message: 'Unsupported LiabilityType name: $value.',
    );
  }

  static String _timestampToString(DateTime value) {
    return value.toUtc().toIso8601String();
  }

  static DateTime _timestampFromString(String value, String path) {
    if (!value.endsWith('Z')) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Timestamp must be a UTC ISO-8601 string.',
      );
    }
    try {
      return DateTime.parse(value).toUtc();
    } on FormatException catch (error) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Timestamp is invalid.',
        cause: error,
      );
    }
  }

  static DateTime? _optionalTimestampFromString(String? value, String path) {
    return value == null ? null : _timestampFromString(value, path);
  }
}
