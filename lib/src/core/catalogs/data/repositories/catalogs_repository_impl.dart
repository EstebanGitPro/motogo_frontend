import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/catalogs/data/datasources/catalogs_data_source.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/service_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

/// Implementation of [CatalogsRepository] that uses [CatalogsDataSource].
class CatalogsRepositoryImpl implements CatalogsRepository {
  final CatalogsDataSource dataSource;

  CatalogsRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, List<BrandEntity>>> getBrands() async {
    final result = await dataSource.getBrands();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<DepartmentEntity>>> getDepartments() async {
    final result = await dataSource.getDepartments();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<CityEntity>>> getCitiesByDepartment(
    String departmentId,
  ) async {
    final result = await dataSource.getCitiesByDepartment(departmentId);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<BranchTypeEntity>>> getBranchTypes() async {
    final result = await dataSource.getBranchTypes();
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<ServiceEntity>>> getServices({
    String? serviceType,
  }) async {
    final result = await dataSource.getServices(serviceType: serviceType);
    return result.map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<Either<ErrorModel, List<String>>> getServiceTypes() async {
    return dataSource.getServiceTypes();
  }
}
