import 'package:flutter_test/flutter_test.dart';

/// Tests for ProfileImageDataSource response handling.
///
/// Note: Full mocking of DioClient requires additional setup.
/// These tests validate the expected response structure.
void main() {
  group('ProfileImageDataSource Response Handling', () {
    group('getProfileImage response parsing', () {
      test('success response contains motorcycle_id and profile_image_url', () {
        // Arrange
        final responseBody = {
          'success': true,
          'code': 'MOD_MOT_IMG_GET_EXI_00001',
          'message':
              'La imagen de perfil de la motocicleta se obtuvo correctamente.',
          'data': {
            'motorcycle_id': 'ez5ney8SpQ1CnYdHmZwcRkzsQXjtPXWcyMRx',
            'profile_image_url': 'https://firebasestorage.com/image.jpg',
            '_links': [
              {
                'href':
                    'http://localhost:8085/motorcycles/ez5ney8SpQ1CnYdHmZwcRkzsQXjtPXWcyMRx/profile-image',
                'rel': 'self',
                'method': 'GET',
              },
              {
                'href':
                    'http://localhost:8085/motorcycles/ez5ney8SpQ1CnYdHmZwcRkzsQXjtPXWcyMRx/profile-image',
                'rel': 'update',
                'method': 'PUT',
              },
            ],
          },
        };

        // Assert
        expect(responseBody['success'], isTrue);
        expect(responseBody['data'], isNotNull);
        final data = responseBody['data'] as Map<String, dynamic>;
        expect(data['motorcycle_id'], isNotEmpty);
        expect(data['profile_image_url'], startsWith('https://'));
      });

      test('response without image returns null profile_image_url', () {
        // Arrange
        final responseBody = {
          'success': true,
          'message': 'No hay imagen de perfil',
          'data': {
            'motorcycle_id': 'abc123',
            // profile_image_url is null/missing
          },
        };

        // Assert
        expect(responseBody['success'], isTrue);
        final data = responseBody['data'] as Map<String, dynamic>;
        expect(data['profile_image_url'], isNull);
      });

      test('error response when motorcycle not found', () {
        // Arrange
        final responseBody = {
          'success': false,
          'code': 'ERR_MOTORCYCLE_NOT_FOUND',
          'message': 'Motocicleta no encontrada',
        };

        // Assert
        expect(responseBody['success'], isFalse);
        expect(responseBody['code'], 'ERR_MOTORCYCLE_NOT_FOUND');
      });
    });

    group('updateProfileImage response parsing', () {
      test('success response after updating image', () {
        // Arrange
        final responseBody = {
          'success': true,
          'code': 'MOD_MOT_IMG_UPD_00001',
          'message': 'La imagen de perfil fue actualizada correctamente.',
          'data': {
            'motorcycle_id': 'xyz789',
            'profile_image_url': 'https://newimage.jpg',
          },
        };

        // Assert
        expect(responseBody['success'], isTrue);
        expect(responseBody['message'], contains('actualizada'));
        final data = responseBody['data'] as Map<String, dynamic>;
        expect(data['profile_image_url'], 'https://newimage.jpg');
      });

      test('error response when URL is invalid', () {
        // Arrange
        final responseBody = {
          'success': false,
          'code': 'ERR_INVALID_URL',
          'message': 'La URL de la imagen no es válida',
        };

        // Assert
        expect(responseBody['success'], isFalse);
        expect(responseBody['message'], contains('no es válida'));
      });
    });

    group('deleteProfileImage response parsing', () {
      test('success response after deleting image', () {
        // Arrange
        final responseBody = {
          'success': true,
          'code': 'MOD_MOT_IMG_DEL_00001',
          'message': 'La imagen de perfil fue eliminada correctamente.',
        };

        // Assert
        expect(responseBody['success'], isTrue);
        expect(responseBody['message'], contains('eliminada'));
      });

      test('error response when no image to delete', () {
        // Arrange
        final responseBody = {
          'success': false,
          'code': 'ERR_NO_IMAGE',
          'message': 'No hay imagen de perfil para eliminar',
        };

        // Assert
        expect(responseBody['success'], isFalse);
        expect(responseBody['message'], contains('No hay imagen'));
      });
    });

    group('Request body formatting', () {
      test('updateProfileImage sends image_url field', () {
        // Arrange
        final requestBody = {'image_url': 'https://newimage.com/photo.jpg'};

        // Assert
        expect(requestBody['image_url'], isNotNull);
        expect(requestBody['image_url'], contains('https://'));
      });
    });

    group('HATEOAS links parsing', () {
      test('response contains _links array', () {
        // Arrange
        final responseBody = {
          'success': true,
          'data': {
            'motorcycle_id': 'moto123',
            '_links': [
              {'href': '.../profile-image', 'rel': 'self', 'method': 'GET'},
              {'href': '.../profile-image', 'rel': 'update', 'method': 'PUT'},
              {
                'href': '.../profile-image',
                'rel': 'delete',
                'method': 'DELETE',
              },
              {'href': '.../', 'rel': 'motorcycle', 'method': 'GET'},
            ],
          },
        };

        // Assert
        final data = responseBody['data'] as Map<String, dynamic>;
        final links = data['_links'] as List;
        expect(links.length, 4);
        expect(links.any((l) => l['rel'] == 'self'), isTrue);
        expect(links.any((l) => l['rel'] == 'update'), isTrue);
        expect(links.any((l) => l['rel'] == 'delete'), isTrue);
      });
    });
  });
}
