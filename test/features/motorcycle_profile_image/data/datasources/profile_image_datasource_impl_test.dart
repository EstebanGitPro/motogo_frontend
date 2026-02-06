import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/data/datasources/profile_image_datasource.dart';

import 'profile_image_datasource_impl_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late ProfileImageDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = ProfileImageDataSourceImpl(mockDioClient);
  });

  // Helper to create Dio Response
  Response<dynamic> createResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  group('ProfileImageDataSourceImpl', () {
    const tMotorcycleId = 'moto-123';
    const tImageUrl = 'https://firebase.storage.com/image.jpg';

    group('updateProfileImage', () {
      test('should return ProfileImageResponse on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'La imagen de perfil fue actualizada correctamente.',
          'data': {
            'motorcycle_id': tMotorcycleId,
            'profile_image_url': tImageUrl,
          },
        };

        when(
          mockDioClient.put(
            '/motorcycles/$tMotorcycleId/profile-image',
            data: {'image_url': tImageUrl},
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.updateProfileImage(
          tMotorcycleId,
          tImageUrl,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.model.motorcycleId, tMotorcycleId);
        expect(result.right.model.profileImageUrl, tImageUrl);
        expect(
          result.right.message,
          'La imagen de perfil fue actualizada correctamente.',
        );
        verify(
          mockDioClient.put(
            '/motorcycles/$tMotorcycleId/profile-image',
            data: {'image_url': tImageUrl},
          ),
        ).called(1);
      });

      test('should return empty message when message is null', () async {
        // Arrange
        final responseData = {
          'success': true,
          'data': {
            'motorcycle_id': tMotorcycleId,
            'profile_image_url': tImageUrl,
          },
        };

        when(
          mockDioClient.put(
            '/motorcycles/$tMotorcycleId/profile-image',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.updateProfileImage(
          tMotorcycleId,
          tImageUrl,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.message, '');
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_MOTORCYCLE_NOT_FOUND',
          'message': 'Motocicleta no encontrada',
        };

        when(
          mockDioClient.put(
            '/motorcycles/$tMotorcycleId/profile-image',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.updateProfileImage(
          tMotorcycleId,
          tImageUrl,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.put(
            '/motorcycles/$tMotorcycleId/profile-image',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.updateProfileImage(
          tMotorcycleId,
          tImageUrl,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.put(
            '/motorcycles/$tMotorcycleId/profile-image',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.updateProfileImage(
          tMotorcycleId,
          tImageUrl,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.put(
            '/motorcycles/$tMotorcycleId/profile-image',
            data: anyNamed('data'),
          ),
        ).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.updateProfileImage(
          tMotorcycleId,
          tImageUrl,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('getProfileImage', () {
      test('should return ProfileImageResponse on success', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'La imagen de perfil se obtuvo correctamente.',
          'data': {
            'motorcycle_id': tMotorcycleId,
            'profile_image_url': tImageUrl,
          },
        };

        when(
          mockDioClient.get('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getProfileImage(tMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.model.motorcycleId, tMotorcycleId);
        expect(result.right.model.profileImageUrl, tImageUrl);
        expect(
          result.right.message,
          'La imagen de perfil se obtuvo correctamente.',
        );
        verify(
          mockDioClient.get('/motorcycles/$tMotorcycleId/profile-image'),
        ).called(1);
      });

      test(
        'should return ProfileImageResponse with null profileImageUrl',
        () async {
          // Arrange
          final responseData = {
            'success': true,
            'message': 'No hay imagen de perfil',
            'data': {
              'motorcycle_id': tMotorcycleId,
              // profile_image_url is null/missing
            },
          };

          when(
            mockDioClient.get('/motorcycles/$tMotorcycleId/profile-image'),
          ).thenAnswer((_) async => createResponse(responseData));

          // Act
          final result = await dataSource.getProfileImage(tMotorcycleId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right.model.motorcycleId, tMotorcycleId);
          expect(result.right.model.profileImageUrl, isNull);
        },
      );

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_MOTORCYCLE_NOT_FOUND',
          'message': 'Motocicleta no encontrada',
        };

        when(
          mockDioClient.get('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.getProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.get('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.getProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.get('/motorcycles/$tMotorcycleId/profile-image'),
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
        final result = await dataSource.getProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.get('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await dataSource.getProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('deleteProfileImage', () {
      test('should return success message on deletion', () async {
        // Arrange
        final responseData = {
          'success': true,
          'message': 'La imagen de perfil fue eliminada correctamente.',
        };

        when(
          mockDioClient.delete('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(
          result.right,
          'La imagen de perfil fue eliminada correctamente.',
        );
        verify(
          mockDioClient.delete('/motorcycles/$tMotorcycleId/profile-image'),
        ).called(1);
      });

      test('should return empty message when message is null', () async {
        // Arrange
        final responseData = {'success': true};

        when(
          mockDioClient.delete('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, '');
      });

      test('should return ErrorModel when success is false', () async {
        // Arrange
        final responseData = {
          'success': false,
          'code': 'ERR_NO_IMAGE',
          'message': 'No hay imagen de perfil para eliminar',
        };

        when(
          mockDioClient.delete('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenAnswer((_) async => createResponse(responseData));

        // Act
        final result = await dataSource.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel when response is not Map', () async {
        // Arrange
        when(
          mockDioClient.delete('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenAnswer((_) async => createResponse('not a map'));

        // Act
        final result = await dataSource.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        // Arrange
        when(
          mockDioClient.delete('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        // Act
        final result = await dataSource.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on generic exception', () async {
        // Arrange
        when(
          mockDioClient.delete('/motorcycles/$tMotorcycleId/profile-image'),
        ).thenThrow(Exception('Delete failed'));

        // Act
        final result = await dataSource.deleteProfileImage(tMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
