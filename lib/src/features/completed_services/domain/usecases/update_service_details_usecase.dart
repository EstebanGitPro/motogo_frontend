import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/repositories/completed_services_repository.dart';

/// Use case for updating the details of a completed service (HU75).
///
/// Calls PATCH /completed-services/{id} via the repository.
/// At least one field must be non-null.
class UpdateServiceDetailsUseCase {
  final CompletedServicesRepository _repository;

  UpdateServiceDetailsUseCase(this._repository);

  Future<Either<ErrorModel, String>> call(
    String serviceId, {
    double? quotedPrice,
    double? finalPrice,
    String? representativeNotes,
  }) {
    return _repository.updateServiceDetails(
      serviceId,
      quotedPrice: quotedPrice,
      finalPrice: finalPrice,
      representativeNotes: representativeNotes,
    );
  }
}
