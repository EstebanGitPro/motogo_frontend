import 'dart:convert';

import 'package:either_dart/either.dart';
import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/catalogs/data/models/brand_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/city_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/department_model.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/errors/http_error_handler.dart';

/// DataSource for fetching catalog data from the API.
abstract class CatalogsDataSource {
  /// Fetches the list of motorcycle brands.
  Future<Either<ErrorModel, List<BrandModel>>> getBrands();

  /// Fetches the list of departments.
  Future<Either<ErrorModel, List<DepartmentModel>>> getDepartments();

  /// Fetches the list of cities for a given department.
  Future<Either<ErrorModel, List<CityModel>>> getCitiesByDepartment(
    String departmentId,
  );
}

class CatalogsDataSourceImpl implements CatalogsDataSource {
  final http.Client client;

  CatalogsDataSourceImpl(this.client);

  @override
  Future<Either<ErrorModel, List<BrandModel>>> getBrands() async {
    try {
      final response = await client
          .get(
            Uri.parse('${Config.baseUrl}/brands'),
            headers: {'Content-Type': 'application/json'},
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

            final brands = BrandModel.fromJsonList(responseData);
            return Right(brands);
          }
        }
        return const Right([]);
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<DepartmentModel>>> getDepartments() async {
    try {
      final response = await client
          .get(
            Uri.parse('${Config.baseUrl}/departments'),
            headers: {'Content-Type': 'application/json'},
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

            final departments = DepartmentModel.fromJsonList(responseData);
            return Right(departments);
          }
        }
        return const Right([]);
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<CityModel>>> getCitiesByDepartment(
    String departmentId,
  ) async {
    try {
      final response = await client
          .get(
            Uri.parse('${Config.baseUrl}/departments/$departmentId/cities'),
            headers: {'Content-Type': 'application/json'},
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

            final cities = CityModel.fromJsonList(responseData);
            return Right(cities);
          }
        }
        return const Right([]);
      } else {
        return Left(HttpErrorHandler.fromHttpResponse(response));
      }
    } catch (e) {
      return HttpErrorHandler.handleException(e);
    }
  }
}
