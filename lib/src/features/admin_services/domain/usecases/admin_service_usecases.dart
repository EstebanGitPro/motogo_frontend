import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/repositories/admin_service_repository.dart';

/// Use case to get all services from the global catalog.
class GetServicesCatalogUseCase {
  final AdminServiceRepository _repository;

  GetServicesCatalogUseCase(this._repository);

  Future<Either<ErrorModel, List<AdminServiceEntity>>> call() {
    return _repository.getServices();
  }
}

/// Use case to update a service in the global catalog (HU68).
class UpdateServiceUseCase {
  final AdminServiceRepository _repository;

  UpdateServiceUseCase(this._repository);

  Future<Either<ErrorModel, AdminServiceEntity>> call({
    required String serviceId,
    required String name,
    required String serviceType,
    String? description,
    bool? isActive,
  }) {
    return _repository.updateService(
      serviceId: serviceId,
      name: name,
      serviceType: serviceType,
      description: description,
      isActive: isActive,
    );
  }
}

/// Use case to activate a service globally (HU71).
class ActivateServiceUseCase {
  final AdminServiceRepository _repository;

  ActivateServiceUseCase(this._repository);

  Future<Either<ErrorModel, String>> call(String serviceId) {
    return _repository.activateService(serviceId);
  }
}

/// Use case to deactivate a service globally (HU72).
class DeactivateServiceUseCase {
  final AdminServiceRepository _repository;

  DeactivateServiceUseCase(this._repository);

  Future<Either<ErrorModel, String>> call(String serviceId) {
    return _repository.deactivateService(serviceId);
  }
}
