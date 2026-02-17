import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/datasource/diagnostic_datasource.dart';

import 'diagnostic_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late DiagnosticDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  dynamic createResponse(dynamic data) {
    return Response(
      data: data,
      requestOptions: RequestOptions(path: ''),
    );
  }

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = DiagnosticDataSourceImpl(mockDioClient);
  });

  const testMotorcycleId = 'moto-123';
  const testDiagnosticId = 'diag-456';

  group('DiagnosticDataSourceImpl', () {
    // ─── createDiagnostic ─────────────────────────────────────────

    group('createDiagnostic', () {
      test('should return DiagnosticResponse on success', () async {
        final responseData = {
          'success': true,
          'message': 'Diagnóstico creado exitosamente',
          'data': {
            'id': testDiagnosticId,
            'motorcycle_id': testMotorcycleId,
            'problem_description': 'Test problem',
            'date': '2026-01-15',
          },
        };

        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/diagnostics',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createDiagnostic(
          motorcycleId: testMotorcycleId,
          problemDescription: 'Test problem',
        );

        expect(result.isRight, isTrue);
        expect(result.right.message, 'Diagnóstico creado exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/diagnostics',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createDiagnostic(
          motorcycleId: testMotorcycleId,
          problemDescription: 'Test problem',
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/diagnostics',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.createDiagnostic(
          motorcycleId: testMotorcycleId,
          problemDescription: 'Test problem',
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/diagnostics',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.createDiagnostic(
          motorcycleId: testMotorcycleId,
          problemDescription: 'Test problem',
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/diagnostics',
            data: anyNamed('data'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.createDiagnostic(
          motorcycleId: testMotorcycleId,
          problemDescription: 'Test problem',
        );

        expect(result.isLeft, isTrue);
      });

      test('should include branchId when provided', () async {
        final responseData = {
          'success': true,
          'message': 'ok',
          'data': {
            'id': testDiagnosticId,
            'motorcycle_id': testMotorcycleId,
            'branch_id': 'branch-1',
            'problem_description': 'Test',
            'date': '2026-01-15',
          },
        };

        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/diagnostics',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createDiagnostic(
          motorcycleId: testMotorcycleId,
          problemDescription: 'Test',
          branchId: 'branch-1',
        );

        expect(result.isRight, isTrue);
      });
    });

    // ─── listDiagnostics ──────────────────────────────────────────

    group('listDiagnostics', () {
      test('should return list of diagnostics from data list', () async {
        final responseData = {
          'success': true,
          'data': [
            {
              'id': 'diag-1',
              'motorcycle_id': testMotorcycleId,
              'problem_description': 'Issue 1',
              'date': '2026-01-01',
            },
          ],
        };

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/diagnostics'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listDiagnostics(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return list from nested items', () async {
        final responseData = {
          'success': true,
          'data': {
            'items': [
              {
                'id': 'diag-1',
                'motorcycle_id': testMotorcycleId,
                'problem_description': 'Issue 1',
                'date': '2026-01-01',
              },
            ],
          },
        };

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/diagnostics'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listDiagnostics(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/diagnostics'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listDiagnostics(
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
          mockDioClient.get('/motorcycles/$testMotorcycleId/diagnostics'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.listDiagnostics(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/diagnostics'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.listDiagnostics(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/diagnostics'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.listDiagnostics(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── getDiagnostic ────────────────────────────────────────────

    group('getDiagnostic', () {
      test('should return DiagnosticModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'id': testDiagnosticId,
            'motorcycle_id': testMotorcycleId,
            'problem_description': 'Test',
            'date': '2026-01-15',
          },
        };

        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isRight, isTrue);
        expect(result.right.id, testDiagnosticId);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── updateDiagnostic ─────────────────────────────────────────

    group('updateDiagnostic', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Diagnóstico actualizado exitosamente',
        };

        when(
          mockDioClient.put(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
          data: {'problem_description': 'Updated'},
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Diagnóstico actualizado exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
          data: {'problem_description': 'Updated'},
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.put(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.updateDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
          data: {'problem_description': 'Updated'},
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.updateDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
          data: {'problem_description': 'Updated'},
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deleteDiagnostic ─────────────────────────────────────────

    group('deleteDiagnostic', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Diagnóstico eliminado exitosamente',
        };

        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Diagnóstico eliminado exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.deleteDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/diagnostics/$testDiagnosticId',
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deleteDiagnostic(
          motorcycleId: testMotorcycleId,
          diagnosticId: testDiagnosticId,
        );

        expect(result.isLeft, isTrue);
      });
    });
  });
}
