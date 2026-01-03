import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';
import 'package:motogo_frontend/src/features/register_person/data/models/person_register_model.dart';

class RegisterPersonDataSource {
  String _deriveIdFromLocationHeader(Map<String, String> headers) {
    final location = headers['location'] ?? headers['Location'];
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
            Uri.parse('${Config.baseUrl}/persons'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        dynamic responseData;
        if (response.body.trim().isNotEmpty) {
          responseData = json.decode(response.body);
        }
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
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }
}
