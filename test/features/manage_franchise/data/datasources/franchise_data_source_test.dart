import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/manage_franchise/data/datasources/franchise_data_source.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';

import 'franchise_data_source_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late FranchiseDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  dynamic createResponse(dynamic data) {
    return Response(
      data: data,
      requestOptions: RequestOptions(path: ''),
    );
  }

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = FranchiseDataSourceImpl(mockDioClient);
  });

  const testFranchiseId = 'franchise-123';

  group('FranchiseDataSourceImpl', () {
    // ─── getFranchise ─────────────────────────────────────────────

    group('getFranchise', () {
      test('should return FranchiseModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'id': testFranchiseId,
            'name': 'Test Franchise',
            'description': 'A test franchise',
          },
        };

        when(
          mockDioClient.get('/franchises/$testFranchiseId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getFranchise(testFranchiseId);

        expect(result.isRight, isTrue);
        expect(result.right.name, 'Test Franchise');
      });

      test('should return ErrorModel when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/franchises/$testFranchiseId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getFranchise(testFranchiseId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get('/franchises/$testFranchiseId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getFranchise(testFranchiseId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.get('/franchises/$testFranchiseId'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getFranchise(testFranchiseId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/franchises/$testFranchiseId')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getFranchise(testFranchiseId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/franchises/$testFranchiseId'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getFranchise(testFranchiseId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── listFranchises ───────────────────────────────────────────

    group('listFranchises', () {
      test('should return list of franchises on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'franchises': [
              {'id': 'f-1', 'name': 'Franchise 1'},
              {'id': 'f-2', 'name': 'Franchise 2'},
            ],
          },
        };

        when(
          mockDioClient.get('/franchises'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listFranchises();

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(2));
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/franchises'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listFranchises();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when franchises is null', () async {
        final responseData = {'success': true, 'data': <String, dynamic>{}};

        when(
          mockDioClient.get('/franchises'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listFranchises();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get('/franchises'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listFranchises();

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.get('/franchises'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.listFranchises();

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/franchises')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.listFranchises();

        expect(result.isLeft, isTrue);
      });
    });

    // ─── updateFranchise ──────────────────────────────────────────

    group('updateFranchise', () {
      test('should return updated FranchiseModel on success', () async {
        final responseData = {
          'success': true,
          'data': {'id': testFranchiseId, 'name': 'Updated Franchise'},
        };

        when(
          mockDioClient.put(
            '/franchises/$testFranchiseId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateFranchise(
          testFranchiseId,
          const FranchiseModel(name: 'Updated Franchise'),
        );

        expect(result.isRight, isTrue);
        expect(result.right.name, 'Updated Franchise');
      });

      test('should return ErrorModel when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.put(
            '/franchises/$testFranchiseId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateFranchise(
          testFranchiseId,
          const FranchiseModel(name: 'Test'),
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put(
            '/franchises/$testFranchiseId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateFranchise(
          testFranchiseId,
          const FranchiseModel(name: 'Test'),
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put(
            '/franchises/$testFranchiseId',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.updateFranchise(
          testFranchiseId,
          const FranchiseModel(name: 'Test'),
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deleteFranchise ──────────────────────────────────────────

    group('deleteFranchise', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Franquicia eliminada exitosamente',
        };

        when(
          mockDioClient.delete('/franchises/$testFranchiseId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteFranchise(testFranchiseId);

        expect(result.isRight, isTrue);
        expect(result.right, 'Franquicia eliminada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.delete('/franchises/$testFranchiseId'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.deleteFranchise(testFranchiseId);

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete('/franchises/$testFranchiseId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteFranchise(testFranchiseId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.delete('/franchises/$testFranchiseId')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deleteFranchise(testFranchiseId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── linkBranch ───────────────────────────────────────────────

    group('linkBranch', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Sede vinculada exitosamente',
        };

        when(
          mockDioClient.post(
            '/franchises/$testFranchiseId/branches',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.linkBranch('branch-1', testFranchiseId);

        expect(result.isRight, isTrue);
        expect(result.right, 'Sede vinculada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.post(
            '/franchises/$testFranchiseId/branches',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.linkBranch('branch-1', testFranchiseId);

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post(
            '/franchises/$testFranchiseId/branches',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.linkBranch('branch-1', testFranchiseId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(
            '/franchises/$testFranchiseId/branches',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.linkBranch('branch-1', testFranchiseId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── unlinkBranch ─────────────────────────────────────────────

    group('unlinkBranch', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Sede desvinculada exitosamente',
        };

        when(
          mockDioClient.delete(
            '/franchises/$testFranchiseId/branches/branch-1',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.unlinkBranch(
          'branch-1',
          testFranchiseId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Sede desvinculada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.delete(
            '/franchises/$testFranchiseId/branches/branch-1',
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.unlinkBranch(
          'branch-1',
          testFranchiseId,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete(
            '/franchises/$testFranchiseId/branches/branch-1',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.unlinkBranch(
          'branch-1',
          testFranchiseId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete(
            '/franchises/$testFranchiseId/branches/branch-1',
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.unlinkBranch(
          'branch-1',
          testFranchiseId,
        );

        expect(result.isLeft, isTrue);
      });
    });
  });
}
