import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/datasources/motorcycle_evidence_datasource.dart';

import 'motorcycle_evidence_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late MotorcycleEvidenceDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  dynamic createResponse(dynamic data) {
    return Response(
      data: data,
      requestOptions: RequestOptions(path: ''),
    );
  }

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = MotorcycleEvidenceDataSourceImpl(mockDioClient);
  });

  const testMotorcycleId = 'moto-123';
  const testEvidenceId = 'ev-456';

  group('MotorcycleEvidenceDataSourceImpl', () {
    // ─── getEvidence ──────────────────────────────────────────────

    group('getEvidence', () {
      test('should return list from data list', () async {
        final responseData = {
          'success': true,
          'data': [
            {
              'id': testEvidenceId,
              'motorcycle_id': testMotorcycleId,
              'image_url': 'https://example.com/img.jpg',
              'created_at': '2026-01-15T10:00:00Z',
            },
          ],
        };

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/evidence'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getEvidence(
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
                'id': testEvidenceId,
                'motorcycle_id': testMotorcycleId,
                'image_url': 'https://example.com/img.jpg',
                'created_at': '2026-01-15T10:00:00Z',
              },
            ],
          },
        };

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/evidence'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getEvidence(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/evidence'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getEvidence(
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
          mockDioClient.get('/motorcycles/$testMotorcycleId/evidence'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getEvidence(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/evidence'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getEvidence(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/evidence'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getEvidence(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/motorcycles/$testMotorcycleId/evidence'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getEvidence(
          motorcycleId: testMotorcycleId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── createEvidence ───────────────────────────────────────────

    group('createEvidence', () {
      test('should return EvidenceResponse on success', () async {
        final responseData = {
          'success': true,
          'message': 'Evidencia creada exitosamente',
          'data': {
            'id': testEvidenceId,
            'motorcycle_id': testMotorcycleId,
            'image_url': 'https://example.com/img.jpg',
            'angle': 'Frontal',
            'created_at': '2026-01-15T10:00:00Z',
          },
        };

        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/evidence',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createEvidence(
          motorcycleId: testMotorcycleId,
          imageUrl: 'https://example.com/img.jpg',
          angle: 'Frontal',
        );

        expect(result.isRight, isTrue);
        expect(result.right.message, 'Evidencia creada exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/evidence',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createEvidence(
          motorcycleId: testMotorcycleId,
          imageUrl: 'https://example.com/img.jpg',
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/evidence',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.createEvidence(
          motorcycleId: testMotorcycleId,
          imageUrl: 'https://example.com/img.jpg',
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(
            '/motorcycles/$testMotorcycleId/evidence',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.createEvidence(
          motorcycleId: testMotorcycleId,
          imageUrl: 'https://example.com/img.jpg',
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deleteEvidence ───────────────────────────────────────────

    group('deleteEvidence', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Evidencia eliminada exitosamente',
        };

        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/evidence/$testEvidenceId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteEvidence(
          motorcycleId: testMotorcycleId,
          evidenceId: testEvidenceId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Evidencia eliminada exitosamente');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/evidence/$testEvidenceId',
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteEvidence(
          motorcycleId: testMotorcycleId,
          evidenceId: testEvidenceId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return default message when response is not Map', () async {
        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/evidence/$testEvidenceId',
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.deleteEvidence(
          motorcycleId: testMotorcycleId,
          evidenceId: testEvidenceId,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete(
            '/motorcycles/$testMotorcycleId/evidence/$testEvidenceId',
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deleteEvidence(
          motorcycleId: testMotorcycleId,
          evidenceId: testEvidenceId,
        );

        expect(result.isLeft, isTrue);
      });
    });
  });
}
