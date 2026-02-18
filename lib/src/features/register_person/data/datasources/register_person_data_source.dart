import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_person/data/models/person_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';

/// DataSource para el registro de personas.
///
/// Usa su propia instancia de Dio (sin interceptor de auth) porque el
/// endpoint de registro es público y no requiere token.
class RegisterPersonDataSource {
  // Dio instance without auth interceptor (register is public endpoint)
  final Dio _dio;

  RegisterPersonDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: Config.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {'Content-Type': 'application/json'},
            ),
          );

  String _deriveIdFromLocationHeader(Headers headers) {
    final location = headers.value('location') ?? headers.value('Location');
    if (location == null || location.isEmpty) {
      return '';
    }
    try {
      final uri = Uri.parse(location);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (_) {}
    return '';
  }

  String _deriveIdFromLinks(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return '';
    }

    final linksRaw = data['_links'];
    if (linksRaw is! List) {
      return '';
    }

    try {
      final links = List<Map<String, dynamic>>.from(linksRaw);
      final self = links.firstWhere(
        (l) => l['rel'] == 'self' && l['href'] is String,
        orElse: () => {},
      );
      final href = self['href'] as String?;
      if (href == null || href.isEmpty) {
        return '';
      }
      final uri = Uri.parse(href);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (_) {}

    return '';
  }

  Future<Either<ErrorModel, PersonModel>> registerPerson(
    RegisterPersonParams params,
  ) async {
    try {
      final body = _buildRequestBody(params);
      final response = await _dio.post('/persons', data: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _parsePersonResponse(response, params);
      }

      return Left(
        DioErrorHandler.fromBackendError(
          response.data is Map<String, dynamic>
              ? response.data
              : {'message': FallbackMessages.registerError},
        ),
      );
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  /// Builds the JSON request body from registration params.
  Map<String, dynamic> _buildRequestBody(RegisterPersonParams params) {
    final body = <String, dynamic>{
      'identity_number': params.identityNumber,
      'first_name': params.firstName,
      'last_name': params.lastName,
      'email': params.email,
      'phone_number': params.phoneNumber,
      'email_verified': false,
      'phone_number_verified': false,
      'password': params.password,
      'role': params.role,
    };
    if (params.secondLastName != null) {
      body['second_last_name'] = params.secondLastName;
    }
    return body;
  }

  /// Parses a successful person registration response.
  Either<ErrorModel, PersonModel> _parsePersonResponse(
    Response<dynamic> response,
    RegisterPersonParams params,
  ) {
    final responseData = response.data;
    final data =
        responseData is Map<String, dynamic> && responseData.containsKey('data')
        ? responseData['data']
        : responseData;

    if (data is Map<String, dynamic> &&
        data.containsKey('identity_number') &&
        data.containsKey('email')) {
      return Right(PersonModel.fromMap(data));
    }

    return Right(_buildFallbackPerson(response.headers, data, params));
  }

  /// Builds a fallback PersonModel from request params when the response
  /// does not include the full person object.
  PersonModel _buildFallbackPerson(
    Headers headers,
    dynamic data,
    RegisterPersonParams params,
  ) {
    String derivedId = _deriveIdFromLocationHeader(headers);
    if (derivedId.isEmpty) {
      derivedId = _deriveIdFromLinks(data);
    }
    return PersonModel.fromMap({
      'id': derivedId,
      'identity_number': params.identityNumber,
      'first_name': params.firstName,
      'last_name': params.lastName,
      'second_last_name': params.secondLastName,
      'email': params.email,
      'phone_number': params.phoneNumber,
      'email_verified': false,
      'phone_number_verified': false,
      'password': params.password,
      'role': params.role,
    });
  }
}
