import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/datasource/diagnostic_permission_datasource.dart';

import 'diagnostic_permission_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late DiagnosticPermissionDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  dynamic createResponse(dynamic data) {
    return Response(
      data: data,
      requestOptions: RequestOptions(path: ''),
    );
  }

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = DiagnosticPermissionDataSourceImpl(mockDioClient);
  });

  const testMotorcycleId = 'moto-123';
  const testBranchId = 'branch-456';

  group('DiagnosticPermissionDataSourceImpl', () {
    // ─── grantPermission ──────────────────────────────────────────

    group('grantPermission', () {
      test('should return PermissionGrantResponse on success', () async {
        final responseData = {
          'success': true,
          'message': 'Permiso otorgado exitosamente',
          'data': {
            'id': 'perm-1',
            'motorcycle_id': testMotorcycleId,
            'branch_id': testBranchId,
            'active': true,
            'granted_at': '2026-01-15T10:00:00Z',
          },
        };

        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/permissions',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.grantPermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
          active: true,
        );

        expect(result.isRight, isTrue);
        expect(result.right.message, 'Permiso otorgado exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/permissions',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.grantPermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
          active: true,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/permissions',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.grantPermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
          active: true,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/permissions',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.grantPermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
          active: true,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/permissions',
            data: anyNamed('data'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.grantPermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
          active: true,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── listPermissions ──────────────────────────────────────────

    group('listPermissions', () {
      test('should return list from data list', () async {
        final responseData = {
          'success': true,
          'data': [
            {
              'id': 'perm-1',
              'motorcycle_id': testMotorcycleId,
              'branch_id': testBranchId,
              'active': true,
              'granted_at': '2026-01-15',
            },
          ],
        };

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/permissions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listPermissions(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return list from nested permissions key', () async {
        final responseData = {
          'success': true,
          'data': {
            'permissions': [
              {
                'id': 'perm-1',
                'motorcycle_id': testMotorcycleId,
                'branch_id': testBranchId,
                'active': true,
                'granted_at': '2026-01-15',
              },
            ],
          },
        };

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/permissions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listPermissions(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return list from nested items key', () async {
        final responseData = {
          'success': true,
          'data': {
            'items': [
              {
                'id': 'perm-1',
                'motorcycle_id': testMotorcycleId,
                'branch_id': testBranchId,
                'active': true,
                'granted_at': '2026-01-15',
              },
            ],
          },
        };

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/permissions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listPermissions(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/permissions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listPermissions(
          motorcycleId: testMotorcycleId,
        );

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
          mockDioClient.get('/motorcycles/$testMotorcycleId/permissions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listPermissions(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/permissions'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.listPermissions(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/permissions'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.listPermissions(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── revokePermission ─────────────────────────────────────────

    group('revokePermission', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Permiso revocado exitosamente',
        };

        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/permissions/$testBranchId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.revokePermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Permiso revocado exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/permissions/$testBranchId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.revokePermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return default message when response is not Map', () async {
        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/permissions/$testBranchId',
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.revokePermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/permissions/$testBranchId',
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.revokePermission(
          motorcycleId: testMotorcycleId,
          branchId: testBranchId,
        );

        expect(result.isLeft, isTrue);
      });
    });
  });
}
