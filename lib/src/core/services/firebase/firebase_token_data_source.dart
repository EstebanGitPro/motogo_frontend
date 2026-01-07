import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';

/// DataSource for obtaining Firebase custom tokens from the backend.
abstract class FirebaseTokenDataSource {
  /// Gets a Firebase custom token from the backend.
  /// Requires the user to be authenticated with Keycloak.
  Future<Either<ErrorModel, String>> getFirebaseToken();
}

class FirebaseTokenDataSourceImpl implements FirebaseTokenDataSource {
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  FirebaseTokenDataSourceImpl(this.client);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Either<ErrorModel, String>> getFirebaseToken() async {
    try {
      final headers = await _getHeaders();

      final response = await client
          .get(
            Uri.parse('${Config.baseUrl}/auth/firebase-token'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);

          if (responseData is Map<String, dynamic>) {
            final success = responseData['success'] as bool?;
            if (success == false) {
              return Left(HttpErrorHandler.fromBackendError(responseData));
            }

            // Extract firebase_token from response
            final data = responseData['data'] as Map<String, dynamic>?;
            final firebaseToken = data?['firebase_token'] as String?;

            if (firebaseToken != null && firebaseToken.isNotEmpty) {
              return Right(firebaseToken);
            }

            return Left(
              ErrorModel(
                message: 'No se pudo obtener el token de Firebase',
                errorCode: 'FIREBASE_TOKEN_MISSING',
              ),
            );
          }
        }
        return Left(
          ErrorModel(
            message: 'Respuesta vacía del servidor',
            errorCode: 'EMPTY_RESPONSE',
          ),
        );
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }
}
