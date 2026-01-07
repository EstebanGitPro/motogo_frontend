import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';

/// DataSource for branch registration operations.
///
/// Handles HTTP communication with the backend API for branch CRUD operations.
abstract class RegisterBranchDataSource {
  Future<Either<ErrorModel, String>> registerBranch(BranchModel branch);
}

class RegisterBranchDataSourceImpl implements RegisterBranchDataSource {
  final http.Client client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  RegisterBranchDataSourceImpl(this.client);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.read(key: 'access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<Either<ErrorModel, String>> registerBranch(BranchModel branch) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode(branch.toJson());

      // DEBUG: Print request body to verify data
      print('📤 Creating branch with payload: $body');

      final response = await client
          .post(
            Uri.parse('${Config.baseUrl}/branches'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Parse response to get success message
        if (response.body.isNotEmpty) {
          final responseData = json.decode(response.body);

          // Handle HATEOAS wrapped response
          if (responseData is Map<String, dynamic>) {
            // Check for success flag
            final success = responseData['success'] as bool?;
            if (success == false) {
              return Left(HttpErrorHandler.fromBackendError(responseData));
            }

            // Extract message from backend
            final message =
                responseData['message'] as String? ??
                'Sede creada exitosamente';
            return Right(message);
          }
        }
        return const Right('Sede creada exitosamente');
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }
}
