import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;

import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';

/// DataSource para operaciones de cambio de contraseña.
abstract class ChangePasswordDataSource {
  /// Cambia la contraseña del usuario autenticado.
  /// Retorna el mensaje de éxito del backend.
  Future<Either<ErrorModel, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  });
}

class ChangePasswordDataSourceImpl implements ChangePasswordDataSource {
  final http.Client _client;

  ChangePasswordDataSourceImpl(this._client);

  @override
  Future<Either<ErrorModel, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${Config.baseUrl}/persons/me/password'),
            headers: _getHeaders(token: token),
            body: json.encode({
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        // Verificar que la respuesta sea exitosa
        if (responseData['success'] != true) {
          return Left(HttpErrorHandler.fromBackendError(responseData));
        }

        final message =
            responseData['message'] as String? ??
            'Contraseña actualizada correctamente';
        return Right(message);
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }

  Map<String, String> _getHeaders({required String token}) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
