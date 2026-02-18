import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/repositories/motorcycle_evidence_repository.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/delete_evidence_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/get_evidence_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/upload_evidence_usecase.dart';

import 'motorcycle_evidence_usecases_test.mocks.dart';

@GenerateMocks([MotorcycleEvidenceRepository, StorageService])
void main() {
  late MockMotorcycleEvidenceRepository mockRepository;
  late MockStorageService mockStorageService;

  final testEvidence = MotorcycleEvidenceEntity(
    id: 'ev-1',
    motorcycleId: 'moto-1',
    imageUrl: 'https://firebase.com/image.jpg',
    angle: 'Frontal',
    description: 'Foto frontal',
    createdAt: DateTime(2026, 1, 15),
  );
  final errorModel = ErrorModel(message: 'Error', errorCode: 'ERR');

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<MotorcycleEvidenceEntity>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, MotorcycleEvidenceEntity>>(
      Right(testEvidence),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockMotorcycleEvidenceRepository();
    mockStorageService = MockStorageService();
  });

  group('GetEvidenceUseCase', () {
    late GetEvidenceUseCase useCase;

    setUp(() {
      useCase = GetEvidenceUseCase(mockRepository);
    });

    test('should return list of evidence on success', () async {
      when(
        mockRepository.getEvidence(motorcycleId: 'moto-1'),
      ).thenAnswer((_) async => Right([testEvidence]));

      final result = await useCase.call(motorcycleId: 'moto-1');

      expect(result.isRight, isTrue);
      expect(result.right.length, 1);
      verify(mockRepository.getEvidence(motorcycleId: 'moto-1')).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.getEvidence(motorcycleId: 'moto-1'),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(motorcycleId: 'moto-1');

      expect(result.isLeft, isTrue);
    });
  });

  group('DeleteEvidenceUseCase', () {
    late DeleteEvidenceUseCase useCase;

    setUp(() {
      useCase = DeleteEvidenceUseCase(repository: mockRepository);
    });

    test('should return success message on success', () async {
      when(
        mockRepository.deleteEvidence(
          motorcycleId: 'moto-1',
          evidenceId: 'ev-1',
        ),
      ).thenAnswer((_) async => const Right('Evidencia eliminada'));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        evidenceId: 'ev-1',
      );

      expect(result.isRight, isTrue);
      expect(result.right, 'Evidencia eliminada');
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.deleteEvidence(
          motorcycleId: 'moto-1',
          evidenceId: 'ev-1',
        ),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        evidenceId: 'ev-1',
      );

      expect(result.isLeft, isTrue);
    });
  });

  group('UploadEvidenceUseCase', () {
    late UploadEvidenceUseCase useCase;

    setUp(() {
      useCase = UploadEvidenceUseCase(
        storageService: mockStorageService,
        repository: mockRepository,
      );
    });

    test('should upload image and create evidence on success', () async {
      final file = File('/tmp/test_photo.jpg');

      when(
        mockStorageService.uploadImage(
          storagePath: anyNamed('storagePath'),
          file: anyNamed('file'),
        ),
      ).thenAnswer((_) async => const Right('https://firebase.com/image.jpg'));

      when(
        mockRepository.createEvidence(
          motorcycleId: 'moto-1',
          imageUrl: 'https://firebase.com/image.jpg',
          angle: 'Frontal',
          description: 'Foto',
        ),
      ).thenAnswer((_) async => Right(testEvidence));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        photoFile: file,
        angle: 'Frontal',
        description: 'Foto',
      );

      expect(result.isRight, isTrue);
      expect(result.right.id, 'ev-1');
    });

    test('should return error when upload fails', () async {
      final file = File('/tmp/test_photo.jpg');

      when(
        mockStorageService.uploadImage(
          storagePath: anyNamed('storagePath'),
          file: anyNamed('file'),
        ),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        photoFile: file,
      );

      expect(result.isLeft, isTrue);
      expect(result.left, errorModel);
      verifyNever(
        mockRepository.createEvidence(
          motorcycleId: anyNamed('motorcycleId'),
          imageUrl: anyNamed('imageUrl'),
        ),
      );
    });

    test('should return error when createEvidence fails', () async {
      final file = File('/tmp/test_photo.png');

      when(
        mockStorageService.uploadImage(
          storagePath: anyNamed('storagePath'),
          file: anyNamed('file'),
        ),
      ).thenAnswer((_) async => const Right('https://firebase.com/image.png'));

      when(
        mockRepository.createEvidence(
          motorcycleId: 'moto-1',
          imageUrl: 'https://firebase.com/image.png',
        ),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        photoFile: file,
      );

      expect(result.isLeft, isTrue);
    });
  });
}
