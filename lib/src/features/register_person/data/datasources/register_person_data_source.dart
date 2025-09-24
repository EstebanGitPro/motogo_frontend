import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
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
            Uri.parse('http://10.0.2.2:8085/v1/motogo/users'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return Right(PersonModel.fromMap(responseData));
      } else {
        final errorData = json.decode(response.body);
        final serverMessage = errorData['message'] as String?;
        final errorMessage = ErrorMessageMapper.mapHttpError(
          response.statusCode,
          serverMessage,
        );
        return Left(
          ErrorModel(message: errorMessage, errorCode: errorData['error_code']),
        );
      }
    } on SocketException {
      return Left(ErrorModel(message: ValidationMessages.networkError));
    } on TimeoutException {
      return Left(ErrorModel(message: ValidationMessages.timeoutError));
    } on http.ClientException {
      return Left(ErrorModel(message: ValidationMessages.connectionFailed));
    } catch (e) {
      return Left(ErrorModel(message: ValidationMessages.genericError));
    }
  }
}
