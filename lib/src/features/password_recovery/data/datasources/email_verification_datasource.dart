import 'dart:io';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';

/// DataSource for email recovery verification.
///
/// Uses its own Dio instance because this is a public endpoint (no auth required).
class EmailRecoveryVerificationDataSource {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Either<ErrorModel, bool>> verifyEmail(String email) async {
    try {
      final response = await _dio.post(
        '/auth/password-reset',
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        return Left(_handleDioError(response));
      }

      final decoded = response.data;
      final status = decoded['status'] as String?;

      if (status == 'success') {
        return Right(true);
      } else {
        return Left(_handleDioError(response));
      }
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } on SocketException {
      return Left(
        _createErrorModel(ErrorMessageMapper.mapHttpError(0, 'network_error')),
      );
    } on FormatException {
      return Left(_createErrorModel('Respuesta inválida del servidor'));
    } catch (e) {
      final message = e.toString().contains('timeout')
          ? ErrorMessageMapper.mapHttpError(408)
          : ErrorMessageMapper.mapHttpError(0, e.toString());
      return Left(_createErrorModel(message));
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

    final mappedMessage = ErrorMessageMapper.mapHttpError(
      response.statusCode ?? 500,
      serverMessage,
    );

    return ErrorModel(
      message: mappedMessage,
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

    final mappedMessage = ErrorMessageMapper.mapHttpError(
      statusCode ?? 0,
      serverMessage,
    );

    return ErrorModel(
      message: mappedMessage,
      errorCode: statusCode?.toString(),
    );
  }

  ErrorModel _createErrorModel(String message, [String? errorCode]) {
    return ErrorModel(message: message, errorCode: errorCode);
  }
}
