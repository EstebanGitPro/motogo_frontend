import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/my_branches/data/datasources/my_branches_data_source.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';

import 'my_branches_data_source_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late MyBranchesDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = MyBranchesDataSourceImpl(mockDioClient);
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

  group('MyBranchesDataSourceImpl', () {
    group('getBranches', () {
      test('should return list of BranchModel on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'code': 'MOD_B_BR_EXI_00001',
          'message': 'Sedes obtenidas exitosamente.',
          'data': {
            'branches': [
              {
                'id': 'branch-1',
                'name': 'MotoGo Centro',
                'establishment_type': 'WORKSHOP',
                'status': 'ACTIVE',
                'location': {
                  'address': 'Calle 123',
                  'city_id': 'city-1',
                  'city_name': 'Bogotá',
                  'department_id': 'dept-1',
                  'department_name': 'Cundinamarca',
                },
              },
              {
                'id': 'branch-2',
                'name': 'MotoGo Norte',
                'establishment_type': 'PARTS_STORE',
                'status': 'ACTIVE',
                'location': {
                  'address': 'Carrera 45',
                  'city_id': 'city-2',
                  'city_name': 'Medellín',
                  'department_id': 'dept-2',
                  'department_name': 'Antioquia',
                },
              },
            ],
          },
        };

        when(
          mockDioClient.get('/branches'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranches();

        // Assert
        expect(result.isRight, isTrue);
        final branches = result.right;
        expect(branches, isA<List<BranchModel>>());
        expect(branches.length, 2);
        expect(branches[0].name, 'MotoGo Centro');
        expect(branches[0].establishmentType, 'WORKSHOP');
        expect(branches[1].name, 'MotoGo Norte');
      });

      test('should return empty list when no branches', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {'branches': []},
        };

        when(
          mockDioClient.get('/branches'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranches();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_AUTH_001',
          'message': 'No autorizado para ver sedes',
        };

        when(
          mockDioClient.get('/branches'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranches();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
        expect(result.left.message, 'No autorizado para ver sedes');
      });

      test('should return empty list when data is null', () async {
        // Arrange
        final responseData = {'success': true, 'data': null};

        when(
          mockDioClient.get('/branches'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranches();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when branches key is missing', () async {
        // Arrange
        final responseData = {'success': true, 'data': {}};

        when(
          mockDioClient.get('/branches'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getBranches();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test(
        'should return ErrorModel on DioException connectionTimeout',
        () async {
          // Arrange
          when(mockDioClient.get('/branches')).thenThrow(
            DioException(
              type: DioExceptionType.connectionTimeout,
              requestOptions: RequestOptions(path: '/branches'),
            ),
          );

          // Act
          final result = await dataSource.getBranches();

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left, isA<ErrorModel>());
        },
      );

      test('should return ErrorModel on DioException badResponse', () async {
        // Arrange
        when(mockDioClient.get('/branches')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: '/branches'),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
              data: {'message': 'Internal server error'},
            ),
          ),
        );

        // Act
        final result = await dataSource.getBranches();

        // Assert
        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.get('/branches'),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.getBranches();

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

        when(mockDioClient.get('/branches')).thenAnswer((_) async => response);

        // Act
        final result = await dataSource.getBranches();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });
    });
  });
}
