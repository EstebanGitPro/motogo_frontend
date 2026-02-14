import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/branch_type_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/brand_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/displacement_range_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/city_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/department_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/service_model.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';

/// DataSource for fetching catalog data from the API.
///
/// Uses DioClient with automatic token refresh.
abstract class CatalogsDataSource {
  /// Fetches the list of motorcycle brands.
  Future<Either<ErrorModel, List<BrandModel>>> getBrands();

  /// Fetches the list of departments.
  Future<Either<ErrorModel, List<DepartmentModel>>> getDepartments();

  /// Fetches the list of cities for a given department.
  Future<Either<ErrorModel, List<CityModel>>> getCitiesByDepartment(
    String departmentId,
  );

  /// Fetches the list of branch establishment types.
  Future<Either<ErrorModel, List<BranchTypeModel>>> getBranchTypes();

  /// Fetches the list of services from the global catalog.
  /// Optionally filters by [serviceType].
  Future<Either<ErrorModel, List<ServiceModel>>> getServices({
    String? serviceType,
  });

  /// Fetches the list of service types.
  Future<Either<ErrorModel, List<String>>> getServiceTypes();

  /// Fetches the list of engine displacement ranges.
  Future<Either<ErrorModel, List<DisplacementRangeModel>>>
  getDisplacementRanges();
}

class CatalogsDataSourceImpl implements CatalogsDataSource {
  final DioClient _dioClient;

  CatalogsDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<BrandModel>>> getBrands() async {
    try {
      final response = await _dioClient.get('/brands');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final brands = BrandModel.fromJsonList(responseData);
        return Right(brands);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<DepartmentModel>>> getDepartments() async {
    try {
      final response = await _dioClient.get('/departments');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final departments = DepartmentModel.fromJsonList(responseData);
        return Right(departments);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<CityModel>>> getCitiesByDepartment(
    String departmentId,
  ) async {
    try {
      final response = await _dioClient.get(
        '/departments/$departmentId/cities',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final cities = CityModel.fromJsonList(responseData);
        return Right(cities);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<BranchTypeModel>>> getBranchTypes() async {
    try {
      final response = await _dioClient.get('/branch-types');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        // Extract data object that contains types array
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final types = BranchTypeModel.fromJsonList(data);
          return Right(types);
        }
        return const Right([]);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<ServiceModel>>> getServices({
    String? serviceType,
  }) async {
    try {
      String endpoint = '/services';
      if (serviceType != null && serviceType.isNotEmpty) {
        endpoint = '/services?type=$serviceType';
      }

      final response = await _dioClient.get(endpoint);
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final servicesList = data['services'] as List<dynamic>?;
          if (servicesList != null) {
            final services = servicesList
                .map(
                  (json) => ServiceModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();
            return Right(services);
          }
        }
        return const Right([]);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<String>>> getServiceTypes() async {
    try {
      final response = await _dioClient.get('/service-types');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final typesList = data['types'] as List<dynamic>?;
          if (typesList != null) {
            final types = typesList
                .map(
                  (json) => (json as Map<String, dynamic>)['value'] as String,
                )
                .toList();
            return Right(types);
          }
        }
        return const Right([]);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, List<DisplacementRangeModel>>>
  getDisplacementRanges() async {
    try {
      final response = await _dioClient.get('/engine-displacements');
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final ranges = DisplacementRangeModel.fromJsonList(responseData);
        return Right(ranges);
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
