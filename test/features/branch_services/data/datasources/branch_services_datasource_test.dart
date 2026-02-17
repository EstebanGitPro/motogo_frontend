import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';

import 'branch_services_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late BranchServicesDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  dynamic createResponse(dynamic data) {
    return Response(
      data: data,
      requestOptions: RequestOptions(path: ''),
    );
  }

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = BranchServicesDataSourceImpl(mockDioClient);
  });

  const testBranchId = 'branch-123';
  const testServiceId = 'svc-456';

  group('BranchServicesDataSourceImpl', () {
    // ─── getBranchServices ────────────────────────────────────────

    group('getBranchServices', () {
      test('should return list of services on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'services': [
              {'id': testServiceId, 'name': 'Cambio de aceite', 'active': true},
            ],
          },
        };

        when(
          mockDioClient.get('/branches/$testBranchId/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getBranchServices(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return empty list when services is null', () async {
        final responseData = {'success': true, 'data': <String, dynamic>{}};

        when(
          mockDioClient.get('/branches/$testBranchId/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getBranchServices(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/branches/$testBranchId/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getBranchServices(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when response is not Map', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/services'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getBranchServices(testBranchId);

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
          mockDioClient.get('/branches/$testBranchId/services'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getBranchServices(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/branches/$testBranchId/services')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getBranchServices(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/services'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getBranchServices(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── associateService ─────────────────────────────────────────

    group('associateService', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Servicio asociado exitosamente',
        };

        when(
          mockDioClient.post(
            '/branches/$testBranchId/services',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.associateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio asociado exitosamente');
      });

      test('should return default message when map without message', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.post(
            '/branches/$testBranchId/services',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.associateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio asociado');
      });

      test('should return default message when response is not Map', () async {
        when(
          mockDioClient.post(
            '/branches/$testBranchId/services',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.associateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio asociado');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post(
            '/branches/$testBranchId/services',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.associateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(
            '/branches/$testBranchId/services',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.associateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── dissociateService ────────────────────────────────────────

    group('dissociateService', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Servicio desasociado exitosamente',
        };

        when(
          mockDioClient.delete(
            '/branches/$testBranchId/services/$testServiceId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.dissociateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio desasociado exitosamente');
      });

      test('should return default message when response is not Map', () async {
        when(
          mockDioClient.delete(
            '/branches/$testBranchId/services/$testServiceId',
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.dissociateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Servicio desasociado');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete(
            '/branches/$testBranchId/services/$testServiceId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.dissociateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete(
            '/branches/$testBranchId/services/$testServiceId',
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.dissociateService(
          testBranchId,
          testServiceId,
        );

        expect(result.isLeft, isTrue);
      });
    });
  });
}
