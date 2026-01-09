import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/constants/error_codes.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/core/user/data/datasources/user_session_data_source.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/login_result.dart';

/// DataSource para el proceso de login.
///
/// Usa su propia instancia de Dio (sin interceptor de auth) porque el
/// endpoint de login es público y no requiere token previo.
/// Usa UserSessionManager para guardar la sesión y UserSessionDataSource
/// para obtener el perfil del usuario.
class LoginDataSource {
  final UserSessionDataSource _userDataSource;

  // Dio instance without auth interceptor (login is public endpoint)
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  LoginDataSource(this._userDataSource);

  /// Realiza el login y guarda la sesión completa en UserSessionManager.
  /// Retorna un LoginResult con el usuario y el mensaje del backend.
  Future<Either<ErrorModel, LoginResult>> loginPerson(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] != true) {
        return Left(DioErrorHandler.fromBackendError(responseData));
      }

      // Extraer mensaje y código del backend
      final backendMessage =
          responseData['message'] as String? ??
          FallbackMessages.operationSuccess;
      final backendCode = responseData['code'] as String? ?? '';

      // Verificar que exista el objeto 'data'
      final data = responseData['data'];
      if (data == null) {
        return Left(
          DioErrorHandler.fromBackendError({
            'message':
                responseData['message'] ??
                FallbackMessages.incompleteServerResponse,
            'code': responseData['code'],
          }),
        );
      }

      // Extraer los tokens del objeto 'data' anidado
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (accessToken == null) {
        return Left(
          ErrorModel(
            message:
                responseData['message'] ??
                FallbackMessages.incompleteServerResponse,
            errorCode: ErrorCodes.missingAccessToken,
          ),
        );
      }

      // Obtener el perfil del usuario usando el datasource centralizado
      final profileResult = await _userDataSource.fetchCurrentUser(accessToken);

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
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
