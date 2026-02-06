import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/dio_error_handler.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/models/motorcycle_evidence_model.dart';

/// Response wrapper that includes both model and backend message.
class EvidenceResponse {
  final MotorcycleEvidenceModel model;
  final String message;

  const EvidenceResponse({required this.model, required this.message});
}

/// DataSource for motorcycle evidence operations (HU16-19).
abstract class MotorcycleEvidenceDataSource {
  /// Gets all evidence for a motorcycle.
  ///
  /// HU18: GET /motorcycles/{id}/evidence
  Future<Either<ErrorModel, List<MotorcycleEvidenceModel>>> getEvidence({
    required String motorcycleId,
  });

  /// Creates evidence for a motorcycle.
  ///
  /// HU16: POST /motorcycles/{id}/evidence
  Future<Either<ErrorModel, EvidenceResponse>> createEvidence({
    required String motorcycleId,
    required String imageUrl,
    String? angle,
    String? description,
  });

  /// Deletes evidence for a motorcycle.
  ///
  /// HU19: DELETE /motorcycles/{id}/evidence/{evidenceId}
  Future<Either<ErrorModel, String>> deleteEvidence({
    required String motorcycleId,
    required String evidenceId,
  });
}

class MotorcycleEvidenceDataSourceImpl implements MotorcycleEvidenceDataSource {
  final DioClient _dioClient;

  MotorcycleEvidenceDataSourceImpl(this._dioClient);

  @override
  Future<Either<ErrorModel, List<MotorcycleEvidenceModel>>> getEvidence({
    required String motorcycleId,
  }) async {
    try {
      final response = await _dioClient.get(
        '/motorcycles/$motorcycleId/evidence',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final data = responseData['data'];
        List<dynamic>? items;
        if (data is List) {
          items = data;
        } else if (data is Map<String, dynamic>) {
          final nestedItems = data['items'];
          if (nestedItems is List) {
            items = nestedItems;
          }
        }

        if (items == null) {
          return const Right([]);
        }

        final evidenceList = items
            .whereType<Map<String, dynamic>>()
            .map(MotorcycleEvidenceModel.fromDataJson)
            .toList();
        return Right(evidenceList);
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, EvidenceResponse>> createEvidence({
    required String motorcycleId,
    required String imageUrl,
    String? angle,
    String? description,
  }) async {
    try {
      final response = await _dioClient.post(
        '/motorcycles/$motorcycleId/evidence',
        data: {
          'image_url': imageUrl,
          if (angle != null) 'angle': angle,
          if (description != null) 'description': description,
        },
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? '';
        return Right(
          EvidenceResponse(
            model: MotorcycleEvidenceModel.fromJson(responseData),
            message: message,
          ),
        );
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }

  @override
  Future<Either<ErrorModel, String>> deleteEvidence({
    required String motorcycleId,
    required String evidenceId,
  }) async {
    try {
      final response = await _dioClient.delete(
        '/motorcycles/$motorcycleId/evidence/$evidenceId',
      );
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool?;
        if (success == false) {
          return Left(DioErrorHandler.fromBackendError(responseData));
        }

        final message = responseData['message'] as String? ?? '';
        return Right(message);
      }

      return Left(DioErrorHandler.fromBackendError(responseData));
    } on DioException catch (e) {
      return DioErrorHandler.handleDioException(e);
    } catch (e) {
      return DioErrorHandler.handleException(e);
    }
  }
}
