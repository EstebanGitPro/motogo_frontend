import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_person/data/datasources/delete_person_data_source.dart';

/// Repository interface for person deletion.
abstract class DeletePersonRepository {
  /// Deletes the authenticated user's account.
  /// Returns success message on success.
  Future<Either<ErrorModel, String>> deleteAccount();
}

/// Implementation of DeletePersonRepository.
class DeletePersonRepositoryImpl implements DeletePersonRepository {
  final DeletePersonDataSource _dataSource;

  DeletePersonRepositoryImpl(this._dataSource);

  @override
  Future<Either<ErrorModel, String>> deleteAccount() {
    return _dataSource.deleteAccount();
  }
}
