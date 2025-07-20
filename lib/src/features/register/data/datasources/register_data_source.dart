import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register/data/models/person_model.dart';
import 'package:motogo_frontend/src/features/register/exceptions/register_exceptions.dart';

class RegisterDataSource {
  Future<PersonModel> registerPerson(
    String identityNumber,
    String firstName,
    String lastName,
    String? secondLastName,
    String email,
    String phoneNumber,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8085/v1/user'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identity_number': identityNumber,
        'first_name': firstName,
        'last_name': lastName,
        'second_last_name': secondLastName,
        'email': email,
        'phone_number': phoneNumber,
        'email_verified': false,
        'phone_number_verified': false,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return PersonModel.fromMap(responseData);
    } else {
      try {
        final errorData = json.decode(response.body);

        ErrorModel errorModel;
        if (errorData is Map<String, dynamic>) {
          errorModel = ErrorModel.fromJson(errorData);
        } else if (errorData is String) {
          errorModel = ErrorModel(message: errorData, isError: true);
        } else {
          errorModel = ErrorModel(
            message: 'Error del servidor: ${errorData.toString()}',
            isError: true,
          );
        }

        if (errorModel.message.contains('email')) {
          throw const EmailAlreadyExistsException();
        } else if (errorModel.message.contains('identity_number')) {
          throw const IdentityNumberExistsException();
        } else {
          throw RegisterValidationException(errorModel.message);
        }
      } catch (e) {
        throw RegisterValidationException(
          'Error del servidor: ${response.body}',
        );
      }
    }
  }
}
