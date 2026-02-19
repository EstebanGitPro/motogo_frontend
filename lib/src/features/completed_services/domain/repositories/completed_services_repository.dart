import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';

/// Repository contract for completed services operations.
abstract class CompletedServicesRepository {
  /// Registers a completed service for a motorcycle.
  ///
  /// Returns the success message from the backend or an error.
  Future<Either<ErrorModel, String>> registerCompletedService(
    RegisterCompletedServiceModel request,
  );

  /// Fetches completed services for a specific branch.
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByBranch(String branchId);

  /// Fetches completed services for a specific motorcycle.
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByMotorcycle(String motorcycleId);

  /// Updates the status of a completed service.
  /// If [finalPrice] is provided, it is sent with the status update.
  Future<Either<ErrorModel, String>> updateServiceStatus(
    String serviceId,
    String newStatus, {
    double? finalPrice,
  });

  /// Updates the details (prices/notes) of a completed service (HU75).
  Future<Either<ErrorModel, String>> updateServiceDetails(
    String serviceId, {
    double? quotedPrice,
    double? finalPrice,
    String? representativeNotes,
  });

  /// Fetches status transitions for a completed service.
  Future<Either<ErrorModel, List<StatusTransitionModel>>> getServiceTransitions(
    String serviceId,
  );

  /// Deletes a completed service.
  Future<Either<ErrorModel, String>> deleteCompletedService(String serviceId);
}
