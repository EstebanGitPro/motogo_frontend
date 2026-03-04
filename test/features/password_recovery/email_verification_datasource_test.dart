import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/datasources/email_verification_datasource.dart';

void main() {
  group('EmailRecoveryVerificationDataSource', () {
    late Dio dio;
    late EmailRecoveryVerificationDataSource dataSource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://test.com'));
      dataSource = EmailRecoveryVerificationDataSource(dio: dio);
    });

    group('verifyEmail', () {
      test('should return true on success response with status', () async {
        const responseJson =
            '{"status": "success", "message": "Email enviado"}';
        dio.httpClientAdapter = _SimpleAdapter(responseJson, 200);

        final result = await dataSource.verifyEmail('test@example.com');

        expect(result.isRight, isTrue);
        expect(result.right, true);
      });

      test(
        'should return true on success response with success flag',
        () async {
          const responseJson = '{"success": true, "message": "Email enviado"}';
          dio.httpClientAdapter = _SimpleAdapter(responseJson, 200);

          final result = await dataSource.verifyEmail('test@example.com');

          expect(result.isRight, isTrue);
          expect(result.right, true);
        },
      );

      test('should return ErrorModel when success is false', () async {
        const responseJson =
            '{"success": false, "message": "Email no encontrado"}';
        dio.httpClientAdapter = _SimpleAdapter(responseJson, 200);

        final result = await dataSource.verifyEmail('notfound@example.com');

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
        expect(result.left.message, 'Email no encontrado');
      });

      test('should return ErrorModel when status is not success', () async {
        const responseJson =
            '{"status": "error", "message": "Email no encontrado"}';
        dio.httpClientAdapter = _SimpleAdapter(responseJson, 200);

        final result = await dataSource.verifyEmail('notfound@example.com');

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on DioException', () async {
        dio.httpClientAdapter = _ExceptionAdapter(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/auth/password-reset'),
          ),
        );

        final result = await dataSource.verifyEmail('timeout@example.com');

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test(
        'should extract server message from DioException response',
        () async {
          dio.httpClientAdapter = _ExceptionAdapter(
            DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/auth/password-reset'),
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 404,
                data: {'message': 'Usuario no existe'},
              ),
            ),
          );

          final result = await dataSource.verifyEmail('noexist@example.com');

          expect(result.isLeft, isTrue);
          expect(result.left.message, contains('Usuario no existe'));
        },
      );

      test('should handle non-Map response data', () async {
        const responseJson = '"just a string"';
        dio.httpClientAdapter = _SimpleAdapter(responseJson, 200);

        final result = await dataSource.verifyEmail('test@example.com');

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should handle FormatException as generic error', () async {
        dio.httpClientAdapter = _FormatExceptionAdapter();

        final result = await dataSource.verifyEmail('test@example.com');

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should handle SocketException as network error', () async {
        dio.httpClientAdapter = _SocketExceptionAdapter();

        final result = await dataSource.verifyEmail('test@example.com');

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}

class _SimpleAdapter extends IOHttpClientAdapter {
  final String jsonBody;
  final int statusCode;

  _SimpleAdapter(this.jsonBody, this.statusCode);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonBody,
      statusCode,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }
}

class _ExceptionAdapter extends IOHttpClientAdapter {
  final DioException exception;

  _ExceptionAdapter(this.exception);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw exception;
  }
}

class _FormatExceptionAdapter extends IOHttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw const FormatException('Bad format');
  }
}

class _SocketExceptionAdapter extends IOHttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    throw const SocketException('No connection');
  }
}
