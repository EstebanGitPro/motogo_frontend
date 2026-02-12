import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/datasources/search_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/models/motorcycle_detail_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/data/repositories/search_motorcycle_repository_impl.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';

import 'search_motorcycle_repository_impl_test.mocks.dart';

@GenerateMocks([SearchMotorcycleDataSource])
void main() {
  late SearchMotorcycleRepositoryImpl repository;
  late MockSearchMotorcycleDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, MotorcycleDetailModel>>(
      Right(
        const MotorcycleDetailModel(
          id: '',
          licensePlate: '',
          year: 0,
          currentMileage: 0,
          reference: MotorcycleReferenceInfoModel(
            brandName: '',
            model: '',
            category: '',
            engineDisplacementCc: 0,
          ),
        ),
      ),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockSearchMotorcycleDataSource();
    repository = SearchMotorcycleRepositoryImpl(mockDataSource);
  });

  group('SearchMotorcycleRepositoryImpl', () {
    const testPlate = 'ABC12D';

    final testModel = const MotorcycleDetailModel(
      id: 'moto-123',
      licensePlate: 'ABC12D',
      year: 2023,
      currentMileage: 5000,
      reference: MotorcycleReferenceInfoModel(
        brandName: 'Yamaha',
        model: 'MT-07',
        category: 'Naked',
        engineDisplacementCc: 689,
      ),
    );

    group('searchByPlate', () {
      test('should return entity when datasource succeeds', () async {
        // Arrange
        when(
          mockDataSource.searchByPlate(testPlate),
        ).thenAnswer((_) async => Right(testModel));

        // Act
        final result = await repository.searchByPlate(testPlate);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isA<MotorcycleDetailEntity>());
        expect(result.right.id, 'moto-123');
        expect(result.right.licensePlate, 'ABC12D');
        verify(mockDataSource.searchByPlate(testPlate)).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'NOT_FOUND',
          message: 'No se encontró la motocicleta',
        );
        when(
          mockDataSource.searchByPlate(testPlate),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await repository.searchByPlate(testPlate);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockDataSource.searchByPlate(testPlate)).called(1);
      });

      test('should call toEntity on the model', () async {
        // Arrange
        when(
          mockDataSource.searchByPlate(testPlate),
        ).thenAnswer((_) async => Right(testModel));

        // Act
        final result = await repository.searchByPlate(testPlate);

        // Assert — verify entity mapping
        expect(result.right.reference.brandName, 'Yamaha');
        expect(result.right.reference.engineDisplacementCc, 689);
      });
    });

    group('setSolution', () {
      const testDiagnosticId = 'diag-123';
      const testSolution = 'Cambiar filtro de aceite';

      test('should return success message when datasource succeeds', () async {
        // Arrange
        const successMessage = 'Solución registrada exitosamente';
        when(
          mockDataSource.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await repository.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(
          mockDataSource.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        ).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'ERR_SOLUTION',
          message: 'Error al registrar solución',
        );
        when(
          mockDataSource.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await repository.setSolution(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
      });
    });
  });
}
