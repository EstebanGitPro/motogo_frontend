import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/branch_type_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/brand_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/city_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/department_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/displacement_range_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/service_model.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/api_response_handler.dart';
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

      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      if (responseData is Map<String, dynamic>) {
        return Right(BrandModel.fromJsonList(responseData));
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

      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      if (responseData is Map<String, dynamic>) {
        return Right(DepartmentModel.fromJsonList(responseData));
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

      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      if (responseData is Map<String, dynamic>) {
        return Right(CityModel.fromJsonList(responseData));
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

      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      final data = validation.right;
      if (data != null) {
        return Right(BranchTypeModel.fromJsonList(data));
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
      return ApiResponseHandler.extractList(
        response.data,
        key: 'services',
        fromJson: ServiceModel.fromJson,
      );
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
      final validation = ApiResponseHandler.validate(response.data);
      if (validation.isLeft) return Left(validation.left);

      final data = validation.right;
      if (data != null) {
        final typesList = data['types'] as List<dynamic>?;
        if (typesList != null) {
          final types = typesList
              .map((json) => (json as Map<String, dynamic>)['value'] as String)
              .toList();
          return Right(types);
        }
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

      final validation = ApiResponseHandler.validate(responseData);
      if (validation.isLeft) return Left(validation.left);

      if (responseData is Map<String, dynamic>) {
        return Right(DisplacementRangeModel.fromJsonList(responseData));
      }
      return const Right([]);
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
