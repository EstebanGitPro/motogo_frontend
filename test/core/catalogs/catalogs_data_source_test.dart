import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/catalogs/data/datasources/catalogs_data_source.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/brand_model.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

import 'catalogs_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late CatalogsDataSourceImpl dataSource;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    dataSource = CatalogsDataSourceImpl(mockClient);
  });

  group('CatalogsDataSourceImpl', () {
    group('getBrands', () {
      test('should return list of BrandModel on success', () async {
        // Arrange
        final responseBody = json.encode({
          'success': true,
          'code': 'MOD_B_BRD_EXI_00001',
          'message': 'Lista de marcas obtenida exitosamente.',
          'data': {
            'brands': [
              {'id': 'brand-1', 'name': 'Honda'},
              {'id': 'brand-2', 'name': 'Yamaha'},
            ],
          },
        });

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isRight, isTrue);
        final brands = result.right;
        expect(brands, isA<List<BrandModel>>());
        expect(brands.length, 2);
        expect(brands[0].name, 'Honda');
        expect(brands[1].name, 'Yamaha');
      });

      test('should return empty list when no brands in response', () async {
        // Arrange
        final responseBody = json.encode({
          'success': true,
          'data': {'brands': []},
        });

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseBody = json.encode({
          'success': false,
          'code': 'ERR_001',
          'message': 'Error al obtener marcas',
        });

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(responseBody, 200));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on HTTP error status', () async {
        // Arrange
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on network exception', () async {
        // Arrange
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when body is empty', () async {
        // Arrange
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('', 200));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });
    });
  });
}
