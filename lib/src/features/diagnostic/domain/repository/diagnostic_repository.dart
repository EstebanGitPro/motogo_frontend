import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';

/// Repository interface for diagnostic operations.
abstract class DiagnosticRepository {
  /// Creates a diagnostic request.
  Future<Either<ErrorModel, DiagnosticEntity>> createDiagnostic({
    required String motorcycleId,
    required String problemDescription,
    String? branchId,
  });

  /// Lists all diagnostics for a motorcycle.
  Future<Either<ErrorModel, List<DiagnosticEntity>>> listDiagnostics({
    required String motorcycleId,
  });

  /// Gets a single diagnostic detail.
  Future<Either<ErrorModel, DiagnosticEntity>> getDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  });

  /// Updates a diagnostic.
  Future<Either<ErrorModel, String>> updateDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
    required Map<String, dynamic> data,
  });

  /// Deletes a diagnostic.
  Future<Either<ErrorModel, String>> deleteDiagnostic({
    required String motorcycleId,
    required String diagnosticId,
  });
}
