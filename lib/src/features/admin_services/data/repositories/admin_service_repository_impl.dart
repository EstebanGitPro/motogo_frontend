import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/admin_services/data/datasources/admin_service_datasource.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/repositories/admin_service_repository.dart';

/// Implementation of AdminServiceRepository.
///
/// Bridges the data layer (DataSource) with the domain layer.
class AdminServiceRepositoryImpl implements AdminServiceRepository {
  final AdminServiceDataSource _dataSource;

  AdminServiceRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, List<AdminServiceEntity>>> getServices() async {
    final result = await _dataSource.getServices();
    return result.fold(
      (error) => Left(error),
      (models) => Right(models.cast<AdminServiceEntity>()),
    );
  }

  @override
  Future<Either<ErrorModel, AdminServiceEntity>> updateService({
    required String serviceId,
    required String name,
    required String serviceType,
    String? description,
    bool? isActive,
  }) async {
    final result = await _dataSource.updateService(
      serviceId: serviceId,
      name: name,
      serviceType: serviceType,
      description: description,
      isActive: isActive,
    );
    return result.fold((error) => Left(error), (model) => Right(model));
  }

  @override
  Future<Either<ErrorModel, String>> activateService(String serviceId) async {
    final result = await _dataSource.activateService(serviceId);
    return result.fold((error) => Left(error), (message) => Right(message));
  }

  @override
  Future<Either<ErrorModel, String>> deactivateService(String serviceId) async {
    final result = await _dataSource.deactivateService(serviceId);
    return result.fold((error) => Left(error), (message) => Right(message));
  }
}
