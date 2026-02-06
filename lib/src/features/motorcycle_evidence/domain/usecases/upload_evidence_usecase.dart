import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/repositories/motorcycle_evidence_repository.dart';

/// Use case for uploading motorcycle evidence.
///
/// This orchestrates:
/// 1. Upload image file to Firebase Storage
/// 2. Register the evidence in the API with the Firebase URL
class UploadEvidenceUseCase {
  final StorageService _storageService;
  final MotorcycleEvidenceRepository _repository;

  UploadEvidenceUseCase({
    required StorageService storageService,
    required MotorcycleEvidenceRepository repository,
  }) : _storageService = storageService,
       _repository = repository;

  /// Uploads a photo as evidence for a motorcycle.
  ///
  /// [motorcycleId] - The motorcycle to attach evidence to
  /// [photoFile] - The photo file to upload
  /// [angle] - Optional angle description (Frontal, Lateral, Trasera)
  /// [description] - Optional description
  Future<Either<ErrorModel, MotorcycleEvidenceEntity>> call({
    required String motorcycleId,
    required File photoFile,
    String? angle,
    String? description,
  }) async {
    // Step 1: Generate unique storage path
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = _getExtension(photoFile.path);
    final storagePath =
        'motorcycles/$motorcycleId/evidence/$timestamp.$extension';

    // Step 2: Upload to Firebase Storage
    final uploadResult = await _storageService.uploadImage(
      storagePath: storagePath,
      file: photoFile,
    );

    if (uploadResult.isLeft) {
      return Left(uploadResult.left);
    }

    final imageUrl = uploadResult.right;

    // Step 3: Register evidence in API
    final createResult = await _repository.createEvidence(
      motorcycleId: motorcycleId,
      imageUrl: imageUrl,
      angle: angle,
      description: description,
    );

    return createResult;
  }

  String _getExtension(String path) {
    final parts = path.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : 'jpg';
  }
}
