import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/catalogs/data/datasources/catalogs_data_source.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/branch_type_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/brand_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/city_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/department_model.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';

import 'catalogs_data_source_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late CatalogsDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = CatalogsDataSourceImpl(mockDioClient);
  });

  // Helper to create Dio Response
  Response<dynamic> createResponse(
    Map<String, dynamic> data, {
    int statusCode = 200,
  }) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('CatalogsDataSourceImpl', () {
    // ========== getBrands Tests ==========
    group('getBrands', () {
      test('should return list of BrandModel on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'code': 'MOD_B_BRD_EXI_00001',
          'message': 'Lista de marcas obtenida exitosamente.',
          'data': {
            'brands': [
              {'id': 'brand-1', 'name': 'Honda'},
              {'id': 'brand-2', 'name': 'Yamaha'},
            ],
          },
        };

        when(
          mockDioClient.get('/brands'),
        ).thenAnswer((_) async => createResponse(responseData));

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
        final responseData = {
          'success': true,
          'data': {'brands': []},
        };

        when(
          mockDioClient.get('/brands'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_001',
          'message': 'Error al obtener marcas',
        };

        when(
          mockDioClient.get('/brands'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
        expect(result.left.message, 'Error al obtener marcas');
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(mockDioClient.get('/brands')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/brands'),
          ),
        );

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.get('/brands'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        // Arrange
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: 'not a map',
          statusCode: 200,
        );

        when(mockDioClient.get('/brands')).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getBrands();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });
    });

    // ========== getDepartments Tests ==========
    group('getDepartments', () {
      test('should return list of DepartmentModel on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'departments': [
              {'id': 'dept-1', 'name': 'Cundinamarca'},
              {'id': 'dept-2', 'name': 'Antioquia'},
            ],
          },
        };

        when(
          mockDioClient.get('/departments'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getDepartments();

        // Assert
        expect(result.isRight, isTrue);
        final departments = result.right;
        expect(departments, isA<List<DepartmentModel>>());
        expect(departments.length, 2);
        expect(departments[0].name, 'Cundinamarca');
      });

      test('should return empty list when no departments', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {'departments': []},
        };

        when(
          mockDioClient.get('/departments'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getDepartments();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_002',
          'message': 'Error al obtener departamentos',
        };

        when(
          mockDioClient.get('/departments'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getDepartments();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error al obtener departamentos');
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(mockDioClient.get('/departments')).thenThrow(
          DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/departments'),
          ),
        );

        // Act
        final result = await dataSource.getDepartments();

        // Assert
        expect(result.isLeft, isTrue);
      });
    });

    // ========== getCitiesByDepartment Tests ==========
    group('getCitiesByDepartment', () {
      const testDepartmentId = 'dept-1';

      test('should return list of CityModel on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'cities': [
              {'id': 'city-1', 'name': 'Bogotá'},
              {'id': 'city-2', 'name': 'Soacha'},
            ],
          },
        };

        when(
          mockDioClient.get('/departments/$testDepartmentId/cities'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getCitiesByDepartment(testDepartmentId);

        // Assert
        expect(result.isRight, isTrue);
        final cities = result.right;
        expect(cities, isA<List<CityModel>>());
        expect(cities.length, 2);
        expect(cities[0].name, 'Bogotá');
      });

      test('should return empty list when no cities', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {'cities': []},
        };

        when(
          mockDioClient.get('/departments/$testDepartmentId/cities'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getCitiesByDepartment(testDepartmentId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_003',
          'message': 'Departamento no encontrado',
        };

        when(
          mockDioClient.get('/departments/$testDepartmentId/cities'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getCitiesByDepartment(testDepartmentId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Departamento no encontrado');
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.get('/departments/$testDepartmentId/cities'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 404,
            ),
          ),
        );

        // Act
        final result = await dataSource.getCitiesByDepartment(testDepartmentId);

        // Assert
        expect(result.isLeft, isTrue);
      });
    });

    // ========== getBranchTypes Tests ==========
    group('getBranchTypes', () {
      test('should return list of BranchTypeModel on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'types': [
              {'code': 'WORKSHOP', 'label': 'Taller'},
              {'code': 'PARTS_STORE', 'label': 'Almacén de repuestos'},
            ],
          },
        };

        when(
          mockDioClient.get('/branch-types'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranchTypes();

        // Assert
        expect(result.isRight, isTrue);
        final types = result.right;
        expect(types, isA<List<BranchTypeModel>>());
        expect(types.length, 2);
        expect(types[0].code, 'WORKSHOP');
        expect(types[0].label, 'Taller');
      });

      test('should return empty list when no types', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {'types': []},
        };

        when(
          mockDioClient.get('/branch-types'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranchTypes();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_004',
          'message': 'Error al obtener tipos de establecimiento',
        };

        when(
          mockDioClient.get('/branch-types'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranchTypes();

        // Assert
        expect(result.isLeft, isTrue);
        expect(
          result.left.message,
          'Error al obtener tipos de establecimiento',
        );
      });

      test('should return empty list when data is null', () async {
        // Arrange
        final responseData = {'success': true, 'data': null};

        when(
          mockDioClient.get('/branch-types'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranchTypes();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(mockDioClient.get('/branch-types')).thenThrow(
          DioException(
            type: DioExceptionType.receiveTimeout,
            requestOptions: RequestOptions(path: '/branch-types'),
          ),
        );

        // Act
        final result = await dataSource.getBranchTypes();

        // Assert
        expect(result.isLeft, isTrue);
      });
    });

    // ========== getDisplacementRanges Tests ==========
    group('getDisplacementRanges', () {
      test('should return list of DisplacementRangeModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'displacements': [
              {'range': 'BAJO'},
              {'range': 'MEDIO'},
              {'range': 'ALTO'},
            ],
          },
        };

        when(
          mockDioClient.get('/engine-displacements'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDisplacementRanges();

        expect(result.isRight, isTrue);
        final ranges = result.right;
        expect(ranges.length, 3);
        expect(ranges[0].range, 'BAJO');
        expect(ranges[1].range, 'MEDIO');
        expect(ranges[2].range, 'ALTO');
      });

      test('should return empty list when no displacements', () async {
        final responseData = {
          'success': true,
          'data': {'displacements': []},
        };

        when(
          mockDioClient.get('/engine-displacements'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDisplacementRanges();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_DISP_001',
          'message': 'Error al obtener rangos de cilindrada',
        };

        when(
          mockDioClient.get('/engine-displacements'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDisplacementRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: 'not a map',
          statusCode: 200,
        );

        when(
          mockDioClient.get('/engine-displacements'),
        ).thenAnswer((_) async => response);

        final result = await dataSource.getDisplacementRanges();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/engine-displacements')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/engine-displacements'),
          ),
        );

        final result = await dataSource.getDisplacementRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/engine-displacements'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getDisplacementRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
