import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';

/// Repository interface for admin service operations.
///
/// This repository handles operations on the global service catalog,
/// which requires ADMIN role.
abstract class AdminServiceRepository {
  /// Gets all services from the global catalog.
  Future<Either<ErrorModel, List<AdminServiceEntity>>> getServices();

  /// Updates a service in the global catalog (HU68).
  ///
  /// Returns the updated service or an error.
  Future<Either<ErrorModel, AdminServiceEntity>> updateService({
    required String serviceId,
    required String name,
    required String serviceType,
    String? description,
    bool? isActive,
  });

  /// Activates a service globally (HU71).
  ///
  /// Returns a success message or an error.
  Future<Either<ErrorModel, String>> activateService(String serviceId);

  /// Deactivates a service globally (HU72).
  ///
  /// Returns a success message or an error.
  Future<Either<ErrorModel, String>> deactivateService(String serviceId);
}
