import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/register_person/data/models/person_register_model.dart';

/// DataSource para el registro de personas.
///
/// Usa su propia instancia de Dio (sin interceptor de auth) porque el
/// endpoint de registro es público y no requiere token.
class RegisterPersonDataSource {
  // Dio instance without auth interceptor (register is public endpoint)
  final Dio _dio = Dio(
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
      final body = <String, dynamic>{
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

      final response = await _dio.post('/persons', data: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        // Manejo de posibles respuestas con envoltura HATEOAS
        final data =
            responseData is Map<String, dynamic> &&
                responseData.containsKey('data')
            ? responseData['data']
            : responseData;

        if (data is Map<String, dynamic> &&
            data.containsKey('identity_number') &&
            data.containsKey('email')) {
          return Right(PersonModel.fromMap(data));
        } else {
          // Si no viene el objeto persona, construimos uno básico con los datos enviados
          // y tratamos de derivar el id desde los _links (si existen)
          String derivedId = _deriveIdFromLocationHeader(response.headers);
          if (derivedId.isEmpty) {
            derivedId = _deriveIdFromLinks(data);
          }
          return Right(
            PersonModel.fromMap({
              'id': derivedId,
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
        }
      } else {
        // Usar el mensaje del backend directamente
        return Left(
          DioErrorHandler.fromBackendError(
            response.data is Map<String, dynamic>
                ? response.data
                : {'message': FallbackMessages.registerError},
          ),
        );
      }
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
