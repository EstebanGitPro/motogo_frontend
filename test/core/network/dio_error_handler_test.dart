import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

void main() {
  group('DioErrorHandler', () {
    group('handleDioException', () {
      test('should return timeout error for connectionTimeout', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.timeoutError);
      });

      test('should return timeout error for sendTimeout', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.timeoutError);
      });

      test('should return timeout error for receiveTimeout', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.timeoutError);
      });

      test('should return network error for connectionError', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.networkError);
      });

      test('should return cancelled error for cancel', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.requestCancelled);
      });

      test('should return SSL error for badCertificate', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.badCertificate,
          requestOptions: RequestOptions(path: '/test'),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.sslCertificateError);
      });

      test('should return network error for unknown with SocketException', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
          error: const SocketException('Connection refused'),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.networkError);
      });

      test(
        'should return generic error for unknown without SocketException',
        () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: '/test'),
            error: Exception('Some error'),
          );

          // Act
          final result = DioErrorHandler.handleDioException<String>(exception);

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left.message, FallbackMessages.genericError);
        },
      );

      test('should extract message from badResponse', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': 'Bad request error', 'code': 'ERR_400'},
          ),
        );

        // Act
        final result = DioErrorHandler.handleDioException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });

    group('handleException', () {
      test('should handle DioException by delegating', () {
        // Arrange
        final exception = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        // Act
        final result = DioErrorHandler.handleException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.timeoutError);
      });

      test('should return network error for SocketException', () {
        // Arrange
        const exception = SocketException('Connection refused');

        // Act
        final result = DioErrorHandler.handleException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.networkError);
      });

      test('should return timeout error for TimeoutException', () {
        // Arrange
        final exception = TimeoutException('Timed out');

        // Act
        final result = DioErrorHandler.handleException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.timeoutError);
      });

      test('should return invalid response for FormatException', () {
        // Arrange
        const exception = FormatException('Invalid format');

        // Act
        final result = DioErrorHandler.handleException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.invalidResponse);
      });

      test(
        'should return timeout error when exception message contains timeout',
        () {
          // Arrange
          final exception = Exception('Connection timeout occurred');

          // Act
          final result = DioErrorHandler.handleException<String>(exception);

          // Assert
          expect(result.isLeft, isTrue);
          expect(result.left.message, FallbackMessages.timeoutError);
        },
      );

      test('should return generic error for unknown exceptions', () {
        // Arrange
        final exception = Exception('Unknown error');

        // Act
        final result = DioErrorHandler.handleException<String>(exception);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, FallbackMessages.genericError);
      });
    });

    group('fromBackendError', () {
      test('should extract message and code from response data', () {
        // Arrange
        final responseData = {
          'success': false,
          'message': 'Validation failed',
          'code': 'ERR_VAL_001',
        };

        // Act
        final result = DioErrorHandler.fromBackendError(responseData);

        // Assert
        expect(result.message, 'Validation failed');
        expect(result.errorCode, 'ERR_VAL_001');
      });

      test('should use fallback when message is null', () {
        // Arrange
        final responseData = {'success': false, 'code': 'ERR_001'};

        // Act
        final result = DioErrorHandler.fromBackendError(responseData);

        // Assert
        expect(result.message, FallbackMessages.genericError);
        expect(result.errorCode, 'ERR_001');
      });

      test('should handle null code', () {
        // Arrange
        final responseData = {'success': false, 'message': 'Some error'};

        // Act
        final result = DioErrorHandler.fromBackendError(responseData);

        // Assert
        expect(result.message, 'Some error');
        expect(result.errorCode, isNull);
      });
    });
  });
}
