import 'package:fyqen/features/portfolio/infrastructure/errors/portfolio_data_mapping_exception.dart';

/// The version 1, persistence-neutral representation of a Portfolio aggregate.
///
/// Required fields are decoded strictly. Unknown fields are ignored so a newer
/// persistence writer can add data without preventing this DTO from reading the
/// fields it understands.
final class PortfolioDto {
  PortfolioDto({
    required this.schemaVersion,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required List<Map<String, Object?>> assets,
    required List<Map<String, Object?>> liabilities,
  }) : _assets = List<Map<String, Object?>>.unmodifiable(assets.map(_copyMap)),
       _liabilities = List<Map<String, Object?>>.unmodifiable(
         liabilities.map(_copyMap),
       ) {
    if (schemaVersion != supportedSchemaVersion) {
      throw PortfolioDataMappingException(
        path: 'schemaVersion',
        message: 'Unsupported schema version: $schemaVersion.',
      );
    }
  }

  factory PortfolioDto.fromMap(Map<String, Object?> map) {
    return PortfolioDto(
      schemaVersion: _requiredInt(map, 'schemaVersion', 'schemaVersion'),
      id: _requiredString(map, 'id', 'id'),
      name: _requiredString(map, 'name', 'name'),
      createdAt: _requiredString(map, 'createdAt', 'createdAt'),
      updatedAt: _requiredString(map, 'updatedAt', 'updatedAt'),
      assets: _decodeAssets(_requiredValue(map, 'assets', 'assets')),
      liabilities: _decodeLiabilities(
        _requiredValue(map, 'liabilities', 'liabilities'),
      ),
    );
  }

  static const int supportedSchemaVersion = 1;

  final int schemaVersion;
  final String id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final List<Map<String, Object?>> _assets;
  final List<Map<String, Object?>> _liabilities;

  List<Map<String, Object?>> get assets => List<Map<String, Object?>>.unmodifiable(
    _assets,
  );

  List<Map<String, Object?>> get liabilities =>
      List<Map<String, Object?>>.unmodifiable(_liabilities);

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'schemaVersion': schemaVersion,
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'assets': _assets.map(Map<String, Object?>.of).toList(),
      'liabilities': _liabilities.map(Map<String, Object?>.of).toList(),
    };
  }

  static List<Map<String, Object?>> _decodeAssets(Object? value) {
    if (value is! List) {
      throw PortfolioDataMappingException(
        path: 'assets',
        message: 'Expected a List.',
      );
    }

    return List<Map<String, Object?>>.unmodifiable(
      List<Map<String, Object?>>.generate(value.length, (int index) {
        return _decodeAsset(value[index], 'assets[$index]');
      }),
    );
  }

  static List<Map<String, Object?>> _decodeLiabilities(Object? value) {
    if (value is! List) {
      throw PortfolioDataMappingException(
        path: 'liabilities',
        message: 'Expected a List.',
      );
    }

    return List<Map<String, Object?>>.unmodifiable(
      List<Map<String, Object?>>.generate(value.length, (int index) {
        return _decodeLiability(value[index], 'liabilities[$index]');
      }),
    );
  }

  static Map<String, Object?> _decodeAsset(Object? value, String path) {
    final Map<String, Object?> map = _decodeMap(value, path);

    return Map<String, Object?>.unmodifiable(<String, Object?>{
      'id': _requiredString(map, 'id', '$path.id'),
      'name': _requiredString(map, 'name', '$path.name'),
      'type': _requiredString(map, 'type', '$path.type'),
      'quantity': _requiredString(map, 'quantity', '$path.quantity'),
      'unitPrice': _requiredString(map, 'unitPrice', '$path.unitPrice'),
      'currencyCode': _requiredString(map, 'currencyCode', '$path.currencyCode'),
      'createdAt': _requiredString(map, 'createdAt', '$path.createdAt'),
      'updatedAt': _requiredString(map, 'updatedAt', '$path.updatedAt'),
      'symbol': _requiredNullableString(map, 'symbol', '$path.symbol'),
    });
  }

  static Map<String, Object?> _decodeLiability(Object? value, String path) {
    final Map<String, Object?> map = _decodeMap(value, path);

    return Map<String, Object?>.unmodifiable(<String, Object?>{
      'id': _requiredString(map, 'id', '$path.id'),
      'name': _requiredString(map, 'name', '$path.name'),
      'type': _requiredString(map, 'type', '$path.type'),
      'outstandingBalance': _requiredString(
        map,
        'outstandingBalance',
        '$path.outstandingBalance',
      ),
      'originalAmount': _requiredString(
        map,
        'originalAmount',
        '$path.originalAmount',
      ),
      'currencyCode': _requiredString(map, 'currencyCode', '$path.currencyCode'),
      'createdAt': _requiredString(map, 'createdAt', '$path.createdAt'),
      'updatedAt': _requiredString(map, 'updatedAt', '$path.updatedAt'),
      'lenderName': _requiredNullableString(
        map,
        'lenderName',
        '$path.lenderName',
      ),
      'dueDate': _requiredNullableString(map, 'dueDate', '$path.dueDate'),
    });
  }

  static Map<String, Object?> _decodeMap(Object? value, String path) {
    if (value is! Map) {
      throw PortfolioDataMappingException(path: path, message: 'Expected a Map.');
    }

    final Map<String, Object?> result = <String, Object?>{};
    for (final MapEntry<Object?, Object?> entry in value.entries) {
      if (entry.key is! String) {
        throw PortfolioDataMappingException(
          path: path,
          message: 'Expected map keys to be Strings.',
        );
      }
      result[entry.key as String] = entry.value;
    }
    return result;
  }

  static Object? _requiredValue(
    Map<String, Object?> map,
    String key,
    String path,
  ) {
    if (!map.containsKey(key) || map[key] == null) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Required field is missing or null.',
      );
    }
    return map[key];
  }

  static int _requiredInt(Map<String, Object?> map, String key, String path) {
    final Object? value = _requiredValue(map, key, path);
    if (value is! int) {
      throw PortfolioDataMappingException(path: path, message: 'Expected an int.');
    }
    if (value != supportedSchemaVersion) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Unsupported schema version: $value.',
      );
    }
    return value;
  }

  static String _requiredString(
    Map<String, Object?> map,
    String key,
    String path,
  ) {
    final Object? value = _requiredValue(map, key, path);
    if (value is! String) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Expected a String.',
      );
    }
    return value;
  }

  static String? _requiredNullableString(
    Map<String, Object?> map,
    String key,
    String path,
  ) {
    if (!map.containsKey(key)) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Required field is missing.',
      );
    }
    final Object? value = map[key];
    if (value != null && value is! String) {
      throw PortfolioDataMappingException(
        path: path,
        message: 'Expected a String or null.',
      );
    }
    return value as String?;
  }

  static Map<String, Object?> _copyMap(Map<String, Object?> value) {
    return Map<String, Object?>.unmodifiable(value);
  }
}
