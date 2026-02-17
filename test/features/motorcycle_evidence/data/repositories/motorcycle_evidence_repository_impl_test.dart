import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/datasources/motorcycle_evidence_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/models/motorcycle_evidence_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/data/repositories/motorcycle_evidence_repository_impl.dart';

import 'motorcycle_evidence_repository_impl_test.mocks.dart';

@GenerateMocks([MotorcycleEvidenceDataSource])
void main() {
  late MotorcycleEvidenceRepositoryImpl repository;
  late MockMotorcycleEvidenceDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<MotorcycleEvidenceModel>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, EvidenceResponse>>(
      Right(
        EvidenceResponse(
          model: const MotorcycleEvidenceModel(
            id: '',
            motorcycleId: '',
            imageUrl: '',
            createdAt: '',
          ),
          message: '',
        ),
      ),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockMotorcycleEvidenceDataSource();
    repository = MotorcycleEvidenceRepositoryImpl(mockDataSource);
  });

  const testMotorcycleId = 'moto-123';

  group('MotorcycleEvidenceRepositoryImpl', () {
    test('getEvidence maps models to entities', () async {
      when(
        mockDataSource.getEvidence(motorcycleId: anyNamed('motorcycleId')),
      ).thenAnswer(
        (_) async => const Right([
          MotorcycleEvidenceModel(
            id: 'ev-1',
            motorcycleId: testMotorcycleId,
            imageUrl: 'https://example.com/img.jpg',
            createdAt: '2026-01-15',
          ),
        ]),
      );

      final result = await repository.getEvidence(
        motorcycleId: testMotorcycleId,
      );

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
    });

    test('getEvidence returns error on failure', () async {
      when(
        mockDataSource.getEvidence(motorcycleId: anyNamed('motorcycleId')),
      ).thenAnswer(
        (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
      );

      final result = await repository.getEvidence(
        motorcycleId: testMotorcycleId,
      );

      expect(result.isLeft, isTrue);
    });

    test('createEvidence maps response to entity', () async {
      when(
        mockDataSource.createEvidence(
          motorcycleId: anyNamed('motorcycleId'),
          imageUrl: anyNamed('imageUrl'),
          angle: anyNamed('angle'),
          description: anyNamed('description'),
        ),
      ).thenAnswer(
        (_) async => Right(
          EvidenceResponse(
            model: const MotorcycleEvidenceModel(
              id: 'ev-1',
              motorcycleId: testMotorcycleId,
              imageUrl: 'https://example.com/img.jpg',
              createdAt: '2026-01-15',
            ),
            message: 'Created',
          ),
        ),
      );

      final result = await repository.createEvidence(
        motorcycleId: testMotorcycleId,
        imageUrl: 'https://example.com/img.jpg',
      );

      expect(result.isRight, isTrue);
      expect(result.right.id, 'ev-1');
    });

    test('deleteEvidence delegates to datasource', () async {
      when(
        mockDataSource.deleteEvidence(
          motorcycleId: anyNamed('motorcycleId'),
          evidenceId: anyNamed('evidenceId'),
        ),
      ).thenAnswer((_) async => const Right('Deleted'));

      final result = await repository.deleteEvidence(
        motorcycleId: testMotorcycleId,
        evidenceId: 'ev-1',
      );

      expect(result.isRight, isTrue);
    });
  });
}
