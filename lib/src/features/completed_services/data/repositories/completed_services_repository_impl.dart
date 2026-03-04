import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/datasources/completed_services_datasource.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/register_completed_service_model.dart';
import 'package:motogo_frontend/src/features/completed_services/data/model/status_transition_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Implementation of [CompletedServicesRepository].
///
/// Delegates to [CompletedServicesDataSource] for API communication.
class CompletedServicesRepositoryImpl implements CompletedServicesRepository {
  final CompletedServicesDataSource _dataSource;

  CompletedServicesRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, String>> registerCompletedService(
    RegisterCompletedServiceModel request,
  ) {
    return _dataSource.registerCompletedService(request);
  }

  @override
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByBranch(String branchId) {
    return _dataSource.getCompletedServicesByBranch(branchId);
  }

  @override
  Future<Either<ErrorModel, List<CompletedServiceModel>>>
  getCompletedServicesByMotorcycle(String motorcycleId) {
    return _dataSource.getCompletedServicesByMotorcycle(motorcycleId);
  }

  @override
  Future<Either<ErrorModel, String>> updateServiceStatus(
    String serviceId,
    String newStatus, {
    double? finalPrice,
  }) {
    return _dataSource.updateServiceStatus(
      serviceId,
      newStatus,
      finalPrice: finalPrice,
    );
  }

  @override
  Future<Either<ErrorModel, String>> updateServiceDetails(
    String serviceId, {
    double? quotedPrice,
    double? finalPrice,
    String? representativeNotes,
  }) {
    return _dataSource.updateServiceDetails(
      serviceId,
      quotedPrice: quotedPrice,
      finalPrice: finalPrice,
      representativeNotes: representativeNotes,
    );
  }

  @override
  Future<Either<ErrorModel, List<StatusTransitionModel>>> getServiceTransitions(
    String serviceId,
  ) {
    return _dataSource.getServiceTransitions(serviceId);
  }

  @override
  Future<Either<ErrorModel, String>> deleteCompletedService(String serviceId) {
    return _dataSource.deleteCompletedService(serviceId);
  }
}
