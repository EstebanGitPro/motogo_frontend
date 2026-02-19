import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';

class PasswordResetDataSource {
  final http.Client client;

  PasswordResetDataSource(this.client);

  Future<Either<ErrorModel, String>> resetPassword(
    String code,
    String newPassword,
  ) async {
    try {
      final response = await client
          .post(
            Uri.parse('${Config.baseUrl}/auth/password-recovery/reset'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'code': code, 'new_password': newPassword}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Extraer mensaje del backend
        final responseData = json.decode(response.body);
        final message =
            responseData['message'] as String? ??
            FallbackMessages.operationSuccess;
        return Right(message);
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }
}
