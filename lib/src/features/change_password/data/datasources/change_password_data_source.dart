import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource para operaciones de cambio de contraseña.
///
/// Nota: Recibe el token como parámetro porque se usa después de obtenerlo
/// del UserSessionManager.
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
  // Uses its own Dio instance because it receives token as parameter
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  @override
  Future<Either<ErrorModel, String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    try {
      final response = await _dio.put(
        '/persons/me/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
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
