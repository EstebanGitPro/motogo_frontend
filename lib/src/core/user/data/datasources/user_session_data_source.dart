import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/core/user/data/models/user_model.dart';

/// DataSource para operaciones relacionadas con la sesión del usuario.
/// Este es el ÚNICO punto de la aplicación que hace llamadas a /persons/me
///
/// Nota: Este datasource recibe el token como parámetro porque se usa
/// durante el login antes de que el token esté guardado en storage.
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
  // Uses its own Dio instance because it receives token as parameter
  // (used during login before token is stored)
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  @override
  Future<Either<ErrorModel, UserModel>> fetchCurrentUser(String token) async {
    try {
      final response = await _dio.get(
        '/persons/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final responseData = response.data as Map<String, dynamic>;

      // Verificar que la respuesta sea exitosa
      if (responseData['success'] != true) {
        return Left(DioErrorHandler.fromBackendError(responseData));
      }

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

      return Right(UserModel.fromMap(data as Map<String, dynamic>));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> updateCurrentUser(
    UserModel user,
    String token,
  ) async {
    try {
      final response = await _dio.put(
        '/persons/me',
        data: user.toUpdateMap(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final responseData = response.data as Map<String, dynamic>;

      // Verificar que la respuesta sea exitosa
      if (responseData['success'] != true) {
        return Left(DioErrorHandler.fromBackendError(responseData));
      }

      // Extraer mensaje del backend
      final message =
          responseData['message'] as String? ??
          FallbackMessages.operationSuccess;
      return Right(message);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
