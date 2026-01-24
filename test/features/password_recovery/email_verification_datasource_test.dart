import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

class TestableEmailRecoveryDataSource {
  final Dio dio;

  TestableEmailRecoveryDataSource(this.dio);

  Future<Either<ErrorModel, bool>> verifyEmail(String email) async {
    try {
      final response = await dio.post(
        '/auth/password-reset',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        return Left(_handleDioError(response));
      }

      final decoded = response.data;
      final status = decoded['status'] as String?;

      if (status == 'success') {
        return const Right(true);
      } else {
        return Left(_handleDioError(response));
      }
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } on SocketException {
      return Left(ErrorModel(message: 'Error de conexión'));
    } on FormatException {
      return Left(ErrorModel(message: 'Respuesta inválida del servidor'));
    } catch (e) {
      return Left(ErrorModel(message: e.toString()));
    }
  }

  ErrorModel _handleDioError(Response<dynamic> response) {
    String? serverMessage;

    try {
      final errorData = response.data;
      if (errorData is Map<String, dynamic>) {
        serverMessage = errorData['message']?.toString();
      }
    } catch (e) {
      serverMessage = null;
    }

    return ErrorModel(
      message: serverMessage ?? 'Error desconocido',
      errorCode: response.statusCode.toString(),
    );
  }

  ErrorModel _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    String? serverMessage;

    try {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        serverMessage = errorData['message']?.toString();
      }
    } catch (_) {
      serverMessage = null;
    }

    return ErrorModel(
      message: serverMessage ?? 'Error de conexión',
      errorCode: statusCode?.toString(),
    );
  }
}

void main() {
  group('EmailRecoveryVerificationDataSource', () {
    late Dio dio;
    late TestableEmailRecoveryDataSource dataSource;

    setUp(() {
      dio = Dio();
      dataSource = TestableEmailRecoveryDataSource(dio);
    });

    group('verifyEmail', () {
      test('should return true on success response', () async {
        const responseJson =
            '{"status": "success", "message": "Email enviado"}';
        dio.httpClientAdapter = _SimpleAdapter(responseJson, 200);

        final result = await dataSource.verifyEmail('test@example.com');

        expect(result.isRight, isTrue);
        expect(result.right, true);
      });

      test('should return ErrorModel when status is not success', () async {
        const responseJson =
            '{"status": "error", "message": "Email no encontrado"}';
        dio.httpClientAdapter = _SimpleAdapter(responseJson, 200);

        final result = await dataSource.verifyEmail('notfound@example.com');

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });

      test('should return ErrorModel on non-200 status code', () async {
        const responseJson = '{"message": "Bad Request"}';
        dio.httpClientAdapter = _SimpleAdapter(responseJson, 400);

        final result = await dataSource.verifyEmail('bad@example.com');

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
        expect(result.left.message, 'Error de conexión');
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
          expect(result.left.message, 'Usuario no existe');
        },
      );
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
