import 'package:flutter_test/flutter_test.dart';

import 'package:fyqen/features/portfolio/infrastructure/dtos/portfolio_dto.dart';
import 'package:fyqen/features/portfolio/infrastructure/errors/portfolio_data_mapping_exception.dart';

void main() {
  Map<String, Object?> completeMap() {
    return <String, Object?>{
      'schemaVersion': 1,
      'id': 'portfolio-1',
      'name': 'Main Portfolio',
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-02T00:00:00.000Z',
      'assets': <Object?>[
        <String, Object?>{
          'id': 'asset-1',
          'name': 'Cash',
          'type': 'cash',
          'quantity': '1.25',
          'unitPrice': '100.01',
          'currencyCode': 'MYR',
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-02T00:00:00.000Z',
          'symbol': 'CASH',
        },
      ],
      'liabilities': <Object?>[
        <String, Object?>{
          'id': 'liability-1',
          'name': 'Loan',
          'type': 'personalLoan',
          'outstandingBalance': '100.01',
          'originalAmount': '200',
          'currencyCode': 'USD',
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-02T00:00:00.000Z',
          'lenderName': 'Lender',
          'dueDate': '2027-01-01T00:00:00.000Z',
        },
      ],
    };
  }

  Matcher mappingErrorAt(String path) {
    return isA<PortfolioDataMappingException>().having(
      (PortfolioDataMappingException error) => error.path,
      'path',
      path,
    );
  }

  group('PortfolioDto', () {
    test('decodes and encodes a complete version 1 map', () {
      final Map<String, Object?> map = completeMap();
      final PortfolioDto dto = PortfolioDto.fromMap(map);

      expect(dto.schemaVersion, 1);
      expect(dto.id, 'portfolio-1');
      expect(dto.assets.single['quantity'], '1.25');
      expect(dto.liabilities.single['dueDate'], '2027-01-01T00:00:00.000Z');
      expect(dto.toMap(), map);
    });

    test('rejects absent, wrong, and unsupported schema versions', () {
      final Map<String, Object?> missing = completeMap()..remove('schemaVersion');
      final Map<String, Object?> wrongType = completeMap()
        ..['schemaVersion'] = '1';
      final Map<String, Object?> unsupported = completeMap()
        ..['schemaVersion'] = 2;

      expect(() => PortfolioDto.fromMap(missing), throwsA(mappingErrorAt('schemaVersion')));
      expect(
        () => PortfolioDto.fromMap(wrongType),
        throwsA(mappingErrorAt('schemaVersion')),
      );
      expect(
        () => PortfolioDto.fromMap(unsupported),
        throwsA(mappingErrorAt('schemaVersion')),
      );
    });

    test('rejects missing and incorrectly typed root fields without defaults', () {
      for (final String key in <String>[
        'id',
        'name',
        'createdAt',
        'updatedAt',
        'assets',
        'liabilities',
      ]) {
        final Map<String, Object?> missing = completeMap()..remove(key);
        expect(() => PortfolioDto.fromMap(missing), throwsA(mappingErrorAt(key)));
      }

      for (final String key in <String>['id', 'name', 'createdAt', 'updatedAt']) {
        final Map<String, Object?> invalid = completeMap()..[key] = 7;
        expect(() => PortfolioDto.fromMap(invalid), throwsA(mappingErrorAt(key)));
      }
      final Map<String, Object?> nullAssets = completeMap()..['assets'] = null;
      final Map<String, Object?> invalidAssets = completeMap()
        ..['assets'] = 'not-a-list';
      final Map<String, Object?> nullLiabilities = completeMap()
        ..['liabilities'] = null;
      final Map<String, Object?> invalidLiabilities = completeMap()
        ..['liabilities'] = 'not-a-list';

      expect(
        () => PortfolioDto.fromMap(invalidAssets),
        throwsA(mappingErrorAt('assets')),
      );
      expect(
        () => PortfolioDto.fromMap(nullAssets),
        throwsA(mappingErrorAt('assets')),
      );
      expect(
        () => PortfolioDto.fromMap(invalidLiabilities),
        throwsA(mappingErrorAt('liabilities')),
      );
      expect(
        () => PortfolioDto.fromMap(nullLiabilities),
        throwsA(mappingErrorAt('liabilities')),
      );
    });

    test('rejects invalid asset structures and reports exact paths', () {
      final Map<String, Object?> itemNotMap = completeMap()
        ..['assets'] = <Object?>['not-a-map'];
      final Map<String, Object?> missingField = completeMap();
      final List<Object?> missingFieldAssets =
          missingField['assets']! as List<Object?>;
      (missingFieldAssets.single as Map<String, Object?>).remove('quantity');
      final Map<String, Object?> wrongDecimalType = completeMap();
      final List<Object?> wrongDecimalAssets =
          wrongDecimalType['assets']! as List<Object?>;
      (wrongDecimalAssets.single as Map<String, Object?>)['unitPrice'] = 1;

      expect(() => PortfolioDto.fromMap(itemNotMap), throwsA(mappingErrorAt('assets[0]')));
      expect(
        () => PortfolioDto.fromMap(missingField),
        throwsA(mappingErrorAt('assets[0].quantity')),
      );
      expect(
        () => PortfolioDto.fromMap(wrongDecimalType),
        throwsA(mappingErrorAt('assets[0].unitPrice')),
      );
    });

    test('rejects invalid liability structures and reports exact paths', () {
      final Map<String, Object?> itemNotMap = completeMap()
        ..['liabilities'] = <Object?>[1];
      final Map<String, Object?> missingField = completeMap();
      final List<Object?> missingFieldLiabilities =
          missingField['liabilities']! as List<Object?>;
      (missingFieldLiabilities.single as Map<String, Object?>).remove('dueDate');
      final Map<String, Object?> wrongFieldType = completeMap();
      final List<Object?> wrongFieldLiabilities =
          wrongFieldType['liabilities']! as List<Object?>;
      (wrongFieldLiabilities.single as Map<String, Object?>)['currencyCode'] = 1;

      expect(
        () => PortfolioDto.fromMap(itemNotMap),
        throwsA(mappingErrorAt('liabilities[0]')),
      );
      expect(
        () => PortfolioDto.fromMap(missingField),
        throwsA(mappingErrorAt('liabilities[0].dueDate')),
      );
      expect(
        () => PortfolioDto.fromMap(wrongFieldType),
        throwsA(mappingErrorAt('liabilities[0].currencyCode')),
      );
    });

    test('defensively copies input collections and output map collections', () {
      final Map<String, Object?> source = completeMap();
      final List<Object?> sourceAssets = List<Object?>.from(
        source['assets']! as List<Object?>,
      );
      source['assets'] = sourceAssets;
      final PortfolioDto dto = PortfolioDto.fromMap(source);
      sourceAssets.clear();

      final List<Map<String, Object?>> exposedAssets = dto.assets;
      final Map<String, Object?> output = dto.toMap();
      final List<Object?> outputAssets = output['assets']! as List<Object?>;
      outputAssets.clear();

      expect(dto.assets, hasLength(1));
      expect(() => exposedAssets.add(<String, Object?>{}), throwsUnsupportedError);
      expect(dto.toMap()['assets'], hasLength(1));
    });

    test('ignores unknown fields while preserving every required field', () {
      final Map<String, Object?> map = completeMap()
        ..['futureField'] = 'ignored';
      final List<Object?> assets = map['assets']! as List<Object?>;
      (assets.single as Map<String, Object?>)['futureField'] = true;

      final Map<String, Object?> output = PortfolioDto.fromMap(map).toMap();

      expect(output.containsKey('futureField'), isFalse);
      expect((output['assets']! as List<Object?>).single, isNot(contains('futureField')));
    });
  });
}
