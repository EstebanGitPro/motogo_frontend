import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/datasources/search_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/models/motorcycle_detail_model.dart';

import 'search_motorcycle_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late SearchMotorcycleDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = SearchMotorcycleDataSourceImpl(mockDioClient);
  });

  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('SearchMotorcycleDataSourceImpl', () {
    group('searchByPlate', () {
      const testPlate = 'ABC123';

      test('should return MotorcycleDetailModel on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'id': 'moto-123',
            'plate': 'ABC123',
            'brand_name': 'AKT',
            'line_name': 'NKD 125',
            'year': 2023,
            'color': 'Rojo',
            'owner_name': 'Juan Pérez',
          },
        };

        when(
          mockDioClient.get(
            '/motorcycles/lookup',
            queryParameters: {'plate': testPlate},
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.searchByPlate(testPlate);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isA<MotorcycleDetailModel>());
        verify(
          mockDioClient.get(
            '/motorcycles/lookup',
            queryParameters: {'plate': testPlate},
          ),
        ).called(1);
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_MOTO_001',
          'message': 'Motocicleta no encontrada',
        };

        when(
          mockDioClient.get(
            '/motorcycles/lookup',
            queryParameters: {'plate': testPlate},
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.searchByPlate(testPlate);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return parse error when data is not Map', () async {
        // Arrange
        final responseData = {'success': true, 'data': 'not a map'};

        when(
          mockDioClient.get(
            '/motorcycles/lookup',
            queryParameters: {'plate': testPlate},
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.searchByPlate(testPlate);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, MotorcycleConstants.parseError);
      });

      test('should return invalid response when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.get(
            '/motorcycles/lookup',
            queryParameters: {'plate': testPlate},
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.searchByPlate(testPlate);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, MotorcycleConstants.invalidServerResponse);
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.get(
            '/motorcycles/lookup',
            queryParameters: {'plate': testPlate},
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.searchByPlate(testPlate);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.get(
            '/motorcycles/lookup',
            queryParameters: {'plate': testPlate},
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.searchByPlate(testPlate);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('setSolution', () {
      const testDiagnosticId = 'diag-123';
      const testSolution = 'Cambiar filtro de aire';

      test('should return success message on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'Solución registrada exitosamente',
        };

        when(
          mockDioClient.patch(
            '/diagnostics/$testDiagnosticId/solution',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, 'Solución registrada exitosamente');
        verify(
          mockDioClient.patch(
            '/diagnostics/$testDiagnosticId/solution',
            data: {'possible_solution': testSolution},
          ),
        ).called(1);
      });

      test('should return empty string when no message', () async {
        // Arrange
        final responseData = {'success': true};

        when(
          mockDioClient.patch(
            '/diagnostics/$testDiagnosticId/solution',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, '');
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_DIAG_001',
          'message': 'Diagnóstico no encontrado',
        };

        when(
          mockDioClient.patch(
            '/diagnostics/$testDiagnosticId/solution',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return invalid response when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.patch(
            '/diagnostics/$testDiagnosticId/solution',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, MotorcycleConstants.invalidServerResponse);
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.patch(
            '/diagnostics/$testDiagnosticId/solution',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
            ),
          ),
        );

        // Act
        final result = await dataSource.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.patch(
            '/diagnostics/$testDiagnosticId/solution',
            data: anyNamed('data'),
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
