import 'package:either_dart/either.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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
      final response = await http.post(
        Uri.parse('https://drft97k5-8085.use2.devtunnels.ms/v1/motogo/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final person = PersonModel.fromMap(data);

        // Guardar el token y el ID del usuario
        await _secureStorage.write(key: 'token', value: person.token);
        await _secureStorage.write(key: 'user_id', value: person.id);

        return Right(person);
      } else {
        return Left(_handleHttpError(response));
      }
    } on SocketException {
      return Left(_createErrorModel(ErrorMessageMapper.mapHttpError(0, 'network_error')));
    } on HttpException {
      return Left(_createErrorModel(ErrorMessageMapper.mapHttpError(0, 'server_error')));
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
      serverMessage
    );
    
    return ErrorModel(
      message: mappedMessage,
      errorCode: response.statusCode.toString(),
    );
  }

  ErrorModel _createErrorModel(String message, [String? errorCode]) {
    return ErrorModel(
      message: message,
      errorCode: errorCode,
    );
  }


}