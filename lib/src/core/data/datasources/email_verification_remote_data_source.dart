import 'dart:convert';
import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_model.dart';

abstract class EmailVerificationRemoteDataSource {
  Future<Either<ErrorModel, bool>> verifyEmail(String email);
}

class EmailVerificationRemoteDataSourceImpl
    implements EmailVerificationRemoteDataSource {
  @override
  Future<Either<ErrorModel, bool>> verifyEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8085/v1/email/status?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isVerified = data['email_verified'] ?? false;
        return Right(isVerified);
      } else {
        return Left(
          ErrorModel(
            message: 'Error al verificar email: ${response.statusCode}',
            isError: true,
          ),
        );
      }
    } catch (e) {
      return Left(
        ErrorModel(message: 'Error al verificar email: $e', isError: true),
      );
    }
  }
}
