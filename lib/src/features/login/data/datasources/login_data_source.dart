import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:motogo_frontend/src/features/login/data/models/person_model.dart';

class LoginDataSource {
  Future<Either<ErrorModel, PersonModel>> loginPerson(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8085/v1/motogo/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Right(PersonModel.fromMap(data));
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