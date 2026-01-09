import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/network/token_response.dart';

void main() {
  group('TokenResponse', () {
    group('constructor', () {
      test('should create TokenResponse with all required fields', () {
        // Act
        final response = TokenResponse(
          accessToken: 'access_token_123',
          refreshToken: 'refresh_token_456',
          expiresIn: 3600,
          tokenType: 'Bearer',
        );

        // Assert
        expect(response.accessToken, 'access_token_123');
        expect(response.refreshToken, 'refresh_token_456');
        expect(response.expiresIn, 3600);
        expect(response.tokenType, 'Bearer');
      });
    });

    group('fromJson', () {
      test('should parse JSON with all fields', () {
        // Arrange
        final json = {
          'access_token': 'new_access_token',
          'refresh_token': 'new_refresh_token',
          'expires_in': 1800,
          'token_type': 'Bearer',
        };

        // Act
        final response = TokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken, 'new_access_token');
        expect(response.refreshToken, 'new_refresh_token');
        expect(response.expiresIn, 1800);
        expect(response.tokenType, 'Bearer');
      });

      test('should use default expiresIn when not provided', () {
        // Arrange
        final json = {'access_token': 'token', 'refresh_token': 'refresh'};

        // Act
        final response = TokenResponse.fromJson(json);

        // Assert
        expect(response.expiresIn, 300);
      });

      test('should use default tokenType when not provided', () {
        // Arrange
        final json = {'access_token': 'token', 'refresh_token': 'refresh'};

        // Act
        final response = TokenResponse.fromJson(json);

        // Assert
        expect(response.tokenType, 'Bearer');
      });

      test('should parse complete response from refresh endpoint', () {
        // Arrange - simulates actual backend response
        final json = {
          'access_token': 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...',
          'refresh_token': 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...',
          'expires_in': 300,
          'token_type': 'Bearer',
        };

        // Act
        final response = TokenResponse.fromJson(json);

        // Assert
        expect(response.accessToken.isNotEmpty, isTrue);
        expect(response.refreshToken.isNotEmpty, isTrue);
        expect(response.expiresIn, 300);
        expect(response.tokenType, 'Bearer');
      });
    });
  });
}
