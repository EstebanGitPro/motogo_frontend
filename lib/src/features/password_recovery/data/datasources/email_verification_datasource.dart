import 'dart:convert';
import 'dart:io';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';

class EmailRecoveryVerificationDataSource {
  final http.Client client;

  EmailRecoveryVerificationDataSource(this.client);

  Future<Either<ErrorModel, bool>> verifyEmail(String email) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/auth/password-reset');
      final response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return Left(_handleHttpError(response));
      }

      final decoded = json.decode(response.body);
      final status = decoded['status'] as String?;

      if (status == 'success') {
        return Right(true);
      } else {
        return Left(_handleHttpError(response));
      }
    } on SocketException {
      return Left(
        _createErrorModel(ErrorMessageMapper.mapHttpError(0, 'network_error')),
      );
    } on HttpException {
      return Left(
        _createErrorModel(ErrorMessageMapper.mapHttpError(0, 'server_error')),
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

  ErrorModel _handleHttpError(http.Response response) {
    String? serverMessage;

    try {
      final errorData = json.decode(response.body);
      serverMessage = errorData['message']?.toString();
    } catch (e) {
      serverMessage = null;
    }

    final mappedMessage = ErrorMessageMapper.mapHttpError(
      response.statusCode,
      serverMessage,
    );

    return ErrorModel(
      message: mappedMessage,
      errorCode: response.statusCode.toString(),
    );
  }

  ErrorModel _createErrorModel(String message, [String? errorCode]) {
    return ErrorModel(message: message, errorCode: errorCode);
  }
}
