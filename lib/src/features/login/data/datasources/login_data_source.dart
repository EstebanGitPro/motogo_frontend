import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';
import 'package:motogo_frontend/src/core/user/data/datasources/user_session_data_source.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/login_result.dart';
import 'dart:convert';

/// DataSource para el proceso de login.
/// Usa UserSessionManager para guardar la sesión y UserSessionDataSource
/// para obtener el perfil del usuario.
class LoginDataSource {
  final UserSessionDataSource _userDataSource;

  LoginDataSource(this._userDataSource);

  /// Realiza el login y guarda la sesión completa en UserSessionManager.
  /// Retorna un LoginResult con el usuario y el mensaje del backend.
  Future<Either<ErrorModel, LoginResult>> loginPerson(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Config.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] != true) {
          return Left(HttpErrorHandler.fromBackendError(responseData));
        }

        // Extraer mensaje y código del backend
        final backendMessage =
            responseData['message'] as String? ?? '¡Bienvenido/a!';
        final backendCode = responseData['code'] as String? ?? '';

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

        // Extraer los tokens del objeto 'data' anidado
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;

        if (accessToken == null) {
          return Left(ErrorModel(message: 'No se recibió el token de acceso'));
        }

        // Obtener el perfil del usuario usando el datasource centralizado
        final profileResult = await _userDataSource.fetchCurrentUser(
          accessToken,
        );

        if (profileResult.isLeft) {
          return Left(profileResult.left);
        }

        final user = profileResult.right;

        // Guardar la sesión completa en UserSessionManager
        await UserSessionManager.instance.saveSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        );

        return Right(
          LoginResult(user: user, message: backendMessage, code: backendCode),
        );
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }
}
