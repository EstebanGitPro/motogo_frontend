import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'dart:convert';
import 'package:motogo_frontend/src/features/login/data/models/person_model.dart';

class LoginDataSource {
  Future<Either<ErrorModel, PersonModel>> loginPerson(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8085/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Right(PersonModel.fromMap(data));
    } else {
      return Left(
        ErrorModel.fromJson(
          json.decode('{"message": "${response.statusCode}"}'),
        ),
      );
    }
  }
}
