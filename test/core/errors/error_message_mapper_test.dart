import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';

void main() {
  group('ErrorMessageMapper', () {
    group('mapServerError', () {
      test('should return generic error for empty message', () {
        final result = ErrorMessageMapper.mapServerError('');
        expect(result, FallbackMessages.genericError);
      });

      test('should return network error for network_error', () {
        final result = ErrorMessageMapper.mapServerError('network_error');
        expect(result, FallbackMessages.networkError);
      });

      test('should return network error for connection_error', () {
        final result = ErrorMessageMapper.mapServerError('connection_error');
        expect(result, FallbackMessages.networkError);
      });

      test('should return server error for server_error', () {
        final result = ErrorMessageMapper.mapServerError('server_error');
        expect(result, FallbackMessages.serverError);
      });

      test('should return server error for internal_server_error', () {
        final result = ErrorMessageMapper.mapServerError(
          'internal_server_error',
        );
        expect(result, FallbackMessages.serverError);
      });

      test('should return timeout error for timeout', () {
        final result = ErrorMessageMapper.mapServerError('timeout');
        expect(result, FallbackMessages.timeoutError);
      });

      test('should return timeout error for request_timeout', () {
        final result = ErrorMessageMapper.mapServerError('request_timeout');
        expect(result, FallbackMessages.timeoutError);
      });

      test('should return original message for unknown codes', () {
        const originalMessage = 'Custom backend error message';
        final result = ErrorMessageMapper.mapServerError(originalMessage);
        expect(result, originalMessage);
      });

      test('should be case-insensitive for internal codes', () {
        final result = ErrorMessageMapper.mapServerError('NETWORK_ERROR');
        expect(result, FallbackMessages.networkError);
      });
    });

    group('mapHttpError', () {
      test('should use server message when available', () {
        const serverMessage = 'Custom server message';
        final result = ErrorMessageMapper.mapHttpError(400, serverMessage);
        expect(result, serverMessage);
      });

      test('should return network error for status code 0', () {
        final result = ErrorMessageMapper.mapHttpError(0);
        expect(result, FallbackMessages.networkError);
      });

      test('should return bad request for status code 400', () {
        final result = ErrorMessageMapper.mapHttpError(400);
        expect(result, FallbackMessages.badRequest);
      });

      test('should return unauthorized for status code 401', () {
        final result = ErrorMessageMapper.mapHttpError(401);
        expect(result, FallbackMessages.unauthorized);
      });

      test('should return forbidden for status code 403', () {
        final result = ErrorMessageMapper.mapHttpError(403);
        expect(result, FallbackMessages.forbidden);
      });

      test('should return not found for status code 404', () {
        final result = ErrorMessageMapper.mapHttpError(404);
        expect(result, FallbackMessages.notFound);
      });

      test('should return timeout for status code 408', () {
        final result = ErrorMessageMapper.mapHttpError(408);
        expect(result, FallbackMessages.timeoutError);
      });

      test('should return conflict for status code 409', () {
        final result = ErrorMessageMapper.mapHttpError(409);
        expect(result, FallbackMessages.conflict);
      });

      test('should return validation error for status code 422', () {
        final result = ErrorMessageMapper.mapHttpError(422);
        expect(result, FallbackMessages.validationError);
      });

      test('should return too many requests for status code 429', () {
        final result = ErrorMessageMapper.mapHttpError(429);
        expect(result, FallbackMessages.tooManyRequests);
      });

      test('should return server error for status code 500', () {
        final result = ErrorMessageMapper.mapHttpError(500);
        expect(result, FallbackMessages.serverError);
      });

      test('should return server error for status code 502', () {
        final result = ErrorMessageMapper.mapHttpError(502);
        expect(result, FallbackMessages.serverError);
      });

      test('should return server error for status code 503', () {
        final result = ErrorMessageMapper.mapHttpError(503);
        expect(result, FallbackMessages.serverError);
      });

      test('should return server error for status code 504', () {
        final result = ErrorMessageMapper.mapHttpError(504);
        expect(result, FallbackMessages.serverError);
      });

      test('should return generic error for unknown status codes', () {
        final result = ErrorMessageMapper.mapHttpError(418);
        expect(result, FallbackMessages.genericError);
      });

      test('should ignore empty server message and use fallback', () {
        final result = ErrorMessageMapper.mapHttpError(400, '');
        expect(result, FallbackMessages.badRequest);
      });

      test('should ignore null server message and use fallback', () {
        final result = ErrorMessageMapper.mapHttpError(404, null);
        expect(result, FallbackMessages.notFound);
      });
    });
  });
}
