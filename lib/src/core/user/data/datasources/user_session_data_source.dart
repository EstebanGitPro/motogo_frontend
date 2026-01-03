import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;

import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';
import 'package:motogo_frontend/src/core/user/data/models/user_model.dart';

/// DataSource para operaciones relacionadas con la sesión del usuario.
/// Este es el ÚNICO punto de la aplicación que hace llamadas a /persons/me
abstract class UserSessionDataSource {
  /// Obtiene el perfil del usuario autenticado desde el backend
  Future<Either<ErrorModel, UserModel>> fetchCurrentUser(String token);

  /// Actualiza el perfil del usuario autenticado
  /// Retorna el mensaje de éxito del backend
  Future<Either<ErrorModel, String>> updateCurrentUser(
    UserModel user,
    String token,
  );
}

class UserSessionDataSourceImpl implements UserSessionDataSource {
  final http.Client _client;

  UserSessionDataSourceImpl(this._client);

  @override
  Future<Either<ErrorModel, UserModel>> fetchCurrentUser(String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${Config.baseUrl}/persons/me'),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;

        // Verificar que la respuesta sea exitosa
        if (responseData['success'] != true) {
          return Left(HttpErrorHandler.fromBackendError(responseData));
        }

        // Verificar que exista el objeto 'data'
        final data = responseData['data'];
        if (data == null) {
          return Left(
            HttpErrorHandler.fromBackendError({
              'message': 'Respuesta del servidor incompleta',
              'code': responseData['code'],
            }),
          );
        }

        return Right(UserModel.fromMap(data as Map<String, dynamic>));
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> updateCurrentUser(
    UserModel user,
    String token,
  ) async {
    try {
      final response = await _client
          .put(
            Uri.parse('${Config.baseUrl}/persons/me'),
            headers: _getHeaders(token: token),
            body: json.encode(user.toUpdateMap()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final message =
            responseData['message'] as String? ??
            'Datos actualizados correctamente';
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
