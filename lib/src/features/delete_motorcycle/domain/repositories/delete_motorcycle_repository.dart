import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/data/datasources/delete_motorcycle_datasource.dart';

/// Repository interface for motorcycle deletion.
abstract class DeleteMotorcycleRepository {
  /// Deletes a motorcycle by ID.
  ///
  /// Returns [Right] with success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> deleteMotorcycle(String id);
}

/// Implementation of [DeleteMotorcycleRepository].
class DeleteMotorcycleRepositoryImpl implements DeleteMotorcycleRepository {
  final DeleteMotorcycleDataSource dataSource;

  DeleteMotorcycleRepositoryImpl(this.dataSource);

  @override
  Future<Either<ErrorModel, String>> deleteMotorcycle(String id) async {
    return await dataSource.deleteMotorcycle(id);
  }
}
