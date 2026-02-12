import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/datasources/register_franchise_data_source.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';

import 'register_franchise_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late RegisterFranchiseDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = RegisterFranchiseDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('RegisterFranchiseDataSourceImpl', () {
    final testFranchise = FranchiseModel(
      id: '',
      name: 'MotoShop Bogotá',
      description: 'Franquicia principal',
      branchIds: ['branch-1', 'branch-2'],
    );

    group('registerFranchise', () {
      test('should return FranchiseModel from data on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'id': 'franchise-123',
            'name': 'MotoShop Bogotá',
            'description': 'Franquicia principal',
            'branch_ids': ['branch-1', 'branch-2'],
          },
        };

        when(
          mockDioClient.post('/franchises', data: anyNamed('data')),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.registerFranchise(testFranchise);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isA<FranchiseModel>());
        expect(result.right.id, 'franchise-123');
        verify(
          mockDioClient.post('/franchises', data: anyNamed('data')),
        ).called(1);
      });

      test('should return fallback model when data is null', () async {
        // Arrange
        final responseData = {'success': true, 'data': null};

        when(
          mockDioClient.post('/franchises', data: anyNamed('data')),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.registerFranchise(testFranchise);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.id, 'generated');
        expect(result.right.name, testFranchise.name);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_FRANCHISE_001',
          'message': 'Error al crear franquicia',
        };

        when(
          mockDioClient.post('/franchises', data: anyNamed('data')),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.registerFranchise(testFranchise);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return parse error when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.post('/franchises', data: anyNamed('data')),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.registerFranchise(testFranchise);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.errorCode, 'PARSE_ERROR');
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.post('/franchises', data: anyNamed('data')),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.registerFranchise(testFranchise);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.post('/franchises', data: anyNamed('data')),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.registerFranchise(testFranchise);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
