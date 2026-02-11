import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/repositories/search_motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/search_motorcycle_by_plate_usecase.dart';

import 'search_motorcycle_by_plate_usecase_test.mocks.dart';

@GenerateMocks([SearchMotorcycleRepository])
void main() {
  late SearchMotorcycleByPlateUseCase useCase;
  late MockSearchMotorcycleRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, MotorcycleDetailEntity>>(
      const Right(
        MotorcycleDetailEntity(
          id: '',
          licensePlate: '',
          year: 0,
          currentMileage: 0,
          reference: MotorcycleReferenceInfoEntity(
            brandName: '',
            model: '',
            category: '',
            engineDisplacementCc: 0,
          ),
        ),
      ),
    );
  });

  setUp(() {
    mockRepository = MockSearchMotorcycleRepository();
    useCase = SearchMotorcycleByPlateUseCase(mockRepository);
  });

  group('SearchMotorcycleByPlateUseCase', () {
    const testPlate = 'ABC12D';

    const testEntity = MotorcycleDetailEntity(
      id: 'moto-123',
      licensePlate: 'ABC12D',
      year: 2023,
      currentMileage: 5000,
      reference: MotorcycleReferenceInfoEntity(
        brandName: 'Yamaha',
        model: 'MT-07',
        category: 'Naked',
        engineDisplacementCc: 689,
      ),
    );

    group('call', () {
      test('should return entity when repository succeeds', () async {
        // Arrange
        when(
          mockRepository.searchByPlate(testPlate),
        ).thenAnswer((_) async => const Right(testEntity));

        // Act
        final result = await useCase.call(testPlate);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, testEntity);
        verify(mockRepository.searchByPlate(testPlate)).called(1);
      });

      test('should return ErrorModel when repository fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'NOT_FOUND',
          message: 'No se encontró la motocicleta',
        );
        when(
          mockRepository.searchByPlate(testPlate),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await useCase.call(testPlate);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockRepository.searchByPlate(testPlate)).called(1);
      });

      test('should delegate to repository with correct plate', () async {
        // Arrange
        const differentPlate = 'XYZ98F';
        when(
          mockRepository.searchByPlate(differentPlate),
        ).thenAnswer((_) async => const Right(testEntity));

        // Act
        await useCase.call(differentPlate);

        // Assert
        verify(mockRepository.searchByPlate(differentPlate)).called(1);
        verifyNever(mockRepository.searchByPlate(testPlate));
      });

      test('should be callable with call syntax', () async {
        // Arrange
        when(
          mockRepository.searchByPlate(testPlate),
        ).thenAnswer((_) async => const Right(testEntity));

        // Act — using call() syntax
        final result = await useCase(testPlate);

        // Assert
        expect(result.isRight, isTrue);
      });
    });
  });
}
