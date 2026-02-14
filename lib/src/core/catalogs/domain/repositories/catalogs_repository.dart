import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

/// Repository interface for catalog operations.
abstract class CatalogsRepository {
  /// Fetches the list of available motorcycle brands.
  Future<Either<ErrorModel, List<BrandEntity>>> getBrands();

  /// Fetches the list of Colombian departments.
  Future<Either<ErrorModel, List<DepartmentEntity>>> getDepartments();

  /// Fetches the list of cities for a given department.
  Future<Either<ErrorModel, List<CityEntity>>> getCitiesByDepartment(
    String departmentId,
  );

  /// Fetches the list of branch establishment types.
  Future<Either<ErrorModel, List<BranchTypeEntity>>> getBranchTypes();

  /// Fetches the list of services from the global catalog.
  Future<Either<ErrorModel, List<ServiceEntity>>> getServices({
    String? serviceType,
  });

  /// Fetches the list of service types.
  Future<Either<ErrorModel, List<String>>> getServiceTypes();

  /// Fetches the list of engine displacement ranges.
  Future<Either<ErrorModel, List<DisplacementRangeEntity>>>
  getDisplacementRanges();
}
