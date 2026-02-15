import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/user_home/data/datasources/nearby_branches_datasource.dart';

import 'nearby_branches_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late NearbyBranchesDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = NearbyBranchesDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('NearbyBranchesDataSourceImpl', () {
    group('getNearbyBranches', () {
      test('should return list of BranchMarkerModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'branches': [
              {
                'id': 'b-1',
                'name': 'Taller Central',
                'type': 'taller',
                'latitude': 4.624335,
                'longitude': -74.063644,
              },
            ],
          },
        };

        when(
          mockDioClient.get(
            '/branches/nearby',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getNearbyBranches(
          latitude: 4.624,
          longitude: -74.063,
        );

        expect(result.isRight, isTrue);
        expect(result.right.length, 1);
        expect(result.right[0].name, 'Taller Central');
      });

      test('should pass type filter mapped to backend format', () async {
        final responseData = {
          'success': true,
          'data': {'branches': <dynamic>[]},
        };

        when(
          mockDioClient.get(
            '/branches/nearby',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        await dataSource.getNearbyBranches(
          latitude: 4.6,
          longitude: -74.0,
          type: 'taller',
        );

        final captured =
            verify(
                  mockDioClient.get(
                    '/branches/nearby',
                    queryParameters: captureAnyNamed('queryParameters'),
                  ),
                ).captured.single
                as Map<String, dynamic>;

        expect(captured['type'], 'WORKSHOP');
      });

      test('should pass brand and displacement filters', () async {
        final responseData = {
          'success': true,
          'data': {'branches': <dynamic>[]},
        };

        when(
          mockDioClient.get(
            '/branches/nearby',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        await dataSource.getNearbyBranches(
          latitude: 4.6,
          longitude: -74.0,
          brand: 'Honda',
          displacementRange: 'BAJO',
        );

        final captured =
            verify(
                  mockDioClient.get(
                    '/branches/nearby',
                    queryParameters: captureAnyNamed('queryParameters'),
                  ),
                ).captured.single
                as Map<String, dynamic>;

        expect(captured['brand'], 'Honda');
        expect(captured['displacement_range'], 'BAJO');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR_001',
          'message': 'Error al obtener sucursales',
        };

        when(
          mockDioClient.get(
            '/branches/nearby',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getNearbyBranches(
          latitude: 4.6,
          longitude: -74.0,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return empty list when response is not a Map', () async {
        when(
          mockDioClient.get(
            '/branches/nearby',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: 'not a map',
            statusCode: 200,
          ),
        );

        final result = await dataSource.getNearbyBranches(
          latitude: 4.6,
          longitude: -74.0,
        );

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.get(
            '/branches/nearby',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getNearbyBranches(
          latitude: 4.6,
          longitude: -74.0,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get(
            '/branches/nearby',
            queryParameters: anyNamed('queryParameters'),
          ),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getNearbyBranches(
          latitude: 4.6,
          longitude: -74.0,
        );

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
