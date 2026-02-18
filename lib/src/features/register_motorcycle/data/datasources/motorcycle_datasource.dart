import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/datasource_response_mixin.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/data/models/motorcycle_model.dart';

/// DataSource for motorcycle registration.
///
/// Handles REST API communication for motorcycle registration.
/// Requires MOTORCYCLIST role.
abstract class MotorcycleDataSource {
  /// Registers a new motorcycle for the current user.
  /// Endpoint: POST /motorcycles
  Future<Either<ErrorModel, String>> registerMotorcycle(MotorcycleModel model);
}

class MotorcycleDataSourceImpl
    with DataSourceResponseMixin
    implements MotorcycleDataSource {
  final DioClient _dioClient;

  MotorcycleDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, String>> registerMotorcycle(MotorcycleModel model) {
    return handleMessageResponse(
      () => _dioClient.post('/motorcycles', data: model.toJson()),
      'Motocicleta registrada exitosamente',
    );
  }
}
