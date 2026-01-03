import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/config/config.dart';

import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

import 'package:motogo_frontend/src/features/edit_profile/data/models/edit_profile_model.dart';

abstract class EditProfileRemoteDataSource {
  Future<Either<ErrorModel, PersonModel>> fetchPerson({
    required String userId,
    required String token,
  });

  Future<Either<ErrorModel, void>> patchPerson(
    PersonModel personModel,
    String token,
  );
}

class EditProfileRemoteDataSourceImpl implements EditProfileRemoteDataSource {
  final http.Client _client;

  EditProfileRemoteDataSourceImpl(this._client);

  @override
  Future<Either<ErrorModel, PersonModel>> fetchPerson({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('${Config.baseUrl}/persons/me'),
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data =
            (json.decode(response.body) as Map<String, dynamic>)["data"];
        return Right(PersonModel.fromMap(data));
      } else {
        final errorData = json.decode(response.body);
        return Left(
          ErrorModel(
            message: ErrorMessageMapper.mapHttpError(
              response.statusCode,
              errorData['message'] as String?,
            ),
            errorCode: errorData['error_code'],
          ),
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

  @override
  Future<Either<ErrorModel, void>> patchPerson(
    PersonModel personModel,
    String token,
  ) async {
    final payload = {
      'first_name': personModel.firstName,
      'last_name': personModel.lastName,
      'second_last_name': personModel.secondLastName,
      'phone_number': personModel.phoneNumber,
    };

    try {
      final response = await _client
          .put(
            Uri.parse('${Config.baseUrl}/persons/me'),
            headers: _getHeaders(token: token),
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 204) {
        return const Right(null);
      } else {
        final errorData = json.decode(response.body);
        return Left(
          ErrorModel(
            message: ErrorMessageMapper.mapHttpError(
              response.statusCode,
              errorData['message'] as String?,
            ),
            errorCode: errorData['error_code'],
          ),
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

  Map<String, String> _getHeaders({required String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
