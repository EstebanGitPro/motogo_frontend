import 'dart:convert';
import 'dart:io';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';

class PasswordResetDataSource {
  final http.Client client;
  final String baseUrl = 'https://drft97k5-8085.use2.devtunnels.ms/v1/motogo';

  PasswordResetDataSource(this.client);

  Future<Either<ErrorModel, void>> resetPassword(
    String code,
    String newPassword,
  ) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/auth/password-recovery/reset'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'code': code, 'new_password': newPassword}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return const Right(null);
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
      String errorMessage;
      if (e.toString().contains('timeout')) {
        errorMessage = ErrorMessageMapper.mapHttpError(408);
      } else {
        errorMessage = ErrorMessageMapper.mapHttpError(0, e.toString());
      }
      return Left(_createErrorModel(errorMessage));
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
