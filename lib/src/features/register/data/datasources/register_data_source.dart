import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register/data/models/person_model.dart';
import 'package:either_dart/either.dart';


class RegisterDataSource {
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
      return Right(PersonModel.fromMap(responseData));
    } else {
      final errorData = json.decode(response.body);
      return Left(ErrorModel.fromJson(errorData));
    }
  }
}
