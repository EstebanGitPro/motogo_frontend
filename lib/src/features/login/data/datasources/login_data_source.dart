import 'package:either_dart/either.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:motogo_frontend/src/features/login/data/models/person_login_model.dart';

class LoginDataSource {
  final _secureStorage = const FlutterSecureStorage();

  Future<Either<ErrorModel, PersonModel>> loginPerson(
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
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('timeout');
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] != true) {
          return Left(
            _createErrorModel(
              responseData['message'] ?? 'Error en el login',
              responseData['code'],
            ),
          );
        }

        // Verificar que exista el objeto 'data' (cuando success:false no viene)
        final data = responseData['data'];
        if (data == null) {
          return Left(
            _createErrorModel(
              'Respuesta del servidor incompleta',
              responseData['code'],
            ),
          );
        }

        // Extraer los tokens del objeto 'data' anidado
        final accessToken = data['access_token'] as String?;
        final refreshToken = data['refresh_token'] as String?;

        if (accessToken == null) {
          return Left(_createErrorModel('No se recibió el token de acceso'));
        }

        // Guardar los tokens
        await _secureStorage.write(key: 'access_token', value: accessToken);
        if (refreshToken != null) {
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        }

        // Obtener el perfil del usuario
        final profileResult = await getProfile(accessToken);

        if (profileResult.isLeft) {
          // Si falla el perfil, limpiar tokens y retornar error
          await _secureStorage.delete(key: 'access_token');
          await _secureStorage.delete(key: 'refresh_token');
          return Left(profileResult.left);
        }

        return Right(profileResult.right);
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

  /// Obtiene el perfil del usuario desde /auth/me
  Future<Either<ErrorModel, PersonModel>> getProfile(String accessToken) async {
    try {
      final response = await http
          .get(
            Uri.parse('${Config.baseUrl}/auth/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('timeout');
            },
          );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Verificar que la respuesta sea exitosa
        if (responseData['success'] != true) {
          return Left(
            _createErrorModel(
              responseData['message'] ?? 'Error al obtener perfil',
              responseData['code'],
            ),
          );
        }

        // Verificar que exista el objeto 'data'
        final data = responseData['data'];
        if (data == null) {
          return Left(
            _createErrorModel(
              'Respuesta del servidor incompleta',
              responseData['code'],
            ),
          );
        }

        // Crear PersonModel con los datos reales del usuario
        final person = PersonModel.fromMap({
          'id': data['id']?.toString() ?? '',
          'identity_number': data['identity_number']?.toString() ?? '',
          'first_name': data['first_name']?.toString() ?? '',
          'last_name': data['last_name']?.toString() ?? '',
          'second_last_name': data['second_last_name']?.toString(),
          'email': data['email']?.toString() ?? '',
          'phone_number': data['phone_number']?.toString() ?? '',
          'role': data['role']?.toString() ?? '',
          'token': accessToken,
        });

        return Right(person);
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
}
