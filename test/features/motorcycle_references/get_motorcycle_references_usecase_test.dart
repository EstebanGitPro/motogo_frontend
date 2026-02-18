import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/data/datasources/motorcycle_reference_datasource.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/data/models/motorcycle_reference_model.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/usecases/get_motorcycle_references_usecase.dart';

import 'get_motorcycle_references_usecase_test.mocks.dart';

@GenerateMocks([MotorcycleReferenceDataSource])
void main() {
  late GetMotorcycleReferencesUseCase useCase;
  late MockMotorcycleReferenceDataSource mockDataSource;

  const testModel = MotorcycleReferenceModel(
    id: 'ref-1',
    brandId: 'brand-1',
    brandName: 'Yamaha',
    model: 'FZ 2.0',
    category: 'Sport',
    engineDisplacementCc: 150,
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<MotorcycleReferenceModel>>>(
      const Right([]),
    );
  });

  setUp(() {
    mockDataSource = MockMotorcycleReferenceDataSource();
    useCase = GetMotorcycleReferencesUseCase(mockDataSource);
  });

  group('GetMotorcycleReferencesUseCase', () {
    test(
      'should return list of entities mapped from models on success',
      () async {
        when(
          mockDataSource.getReferences(),
        ).thenAnswer((_) async => const Right([testModel]));

        final result = await useCase.call();

        expect(result.isRight, isTrue);
        expect(result.right.length, 1);
        expect(result.right.first.brandName, 'Yamaha');
        expect(result.right.first.model, 'FZ 2.0');
        verify(mockDataSource.getReferences()).called(1);
      },
    );

    test('should return empty list when no references', () async {
      when(
        mockDataSource.getReferences(),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase.call();

      expect(result.isRight, isTrue);
      expect(result.right, isEmpty);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Error', errorCode: 'ERR');
      when(mockDataSource.getReferences()).thenAnswer((_) async => Left(error));

      final result = await useCase.call();

      expect(result.isLeft, isTrue);
      expect(result.left, error);
    });
  });
}
