import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_messages.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';

/// DataSource for motorcycle deletion operations.
///
/// Uses DioClient with automatic token refresh.
abstract class DeleteMotorcycleDataSource {
  /// Deletes a motorcycle by its ID.
  ///
  /// Returns [Right] with the success message on success,
  /// or [Left] with [ErrorModel] on failure.
  Future<Either<ErrorModel, String>> deleteMotorcycle(String id);
}

class DeleteMotorcycleDataSourceImpl
    with DataSourceResponseMixin
    implements DeleteMotorcycleDataSource {
  final DioClient _dioClient;

  DeleteMotorcycleDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> deleteMotorcycle(String id) {
    return handleMessageResponse(
      () => _dioClient.delete('/motorcycles/$id'),
      FallbackMessages.operationSuccess,
    );
  }
}
