import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/data/models/person_register_model.dart';

class RegisterPersonDataSource {
  Future<Either<ErrorModel, PersonModel>> registerPerson(
    String identityNumber,
    String firstName,
    String lastName,
    String? secondLastName,
    String email,
    String phoneNumber,
    String password,
    String role,
  ) async {
    try {
      var body = {
        'identity_number': identityNumber,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'email_verified': false,
        'phone_number_verified': false,
        'password': password,
        'role': role,
      };
      if (secondLastName != null) {
        body['second_last_name'] = secondLastName;
      }
      final response = await http
          .post(
            Uri.parse('${Config.baseUrl}/users'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Right(PersonModel.fromMap(responseData));
      } else {
        final errorData = json.decode(response.body);
        
        // Consumir mensajes directamente del backend
        final errorModel = ErrorModel.fromJson({
          'message': errorData['message'] ?? 'Error al registrar usuario',
          'description': errorData['description'],
          'status_code': response.statusCode,
          'error_code': errorData['error_code'],
          'details': errorData['details'] ?? errorData['errors'],
        });
        
        return Left(errorModel);
      }
    } on SocketException {
      return Left(ErrorModel(
        message: 'Error de red',
        description: 'No hay conexión a internet',
        statusCode: 0,
        errorCode: 'NETWORK_ERROR',
      ));
    } on TimeoutException {
      return Left(ErrorModel(
        message: 'Tiempo agotado',
        description: 'La solicitud tardó demasiado tiempo',
        statusCode: 408,
        errorCode: 'TIMEOUT_ERROR',
      ));
    } on http.ClientException {
      return Left(ErrorModel(
        message: 'Error de conexión',
        description: 'No se pudo establecer conexión con el servidor',
        statusCode: 0,
        errorCode: 'CONNECTION_ERROR',
      ));
    } catch (e) {
      return Left(ErrorModel(
        message: 'Error del cliente',
        description: 'Error al procesar la solicitud',
        statusCode: 500,
        errorCode: 'CLIENT_ERROR',
      ));
    }
  }
}
