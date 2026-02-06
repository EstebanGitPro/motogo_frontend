import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/data/datasources/delete_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/repositories/delete_motorcycle_repository.dart';

import 'delete_motorcycle_repository_test.mocks.dart';

@GenerateMocks([DeleteMotorcycleDataSource])
void main() {
  late DeleteMotorcycleRepositoryImpl repository;
  late MockDeleteMotorcycleDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockDeleteMotorcycleDataSource();
    repository = DeleteMotorcycleRepositoryImpl(mockDataSource);
  });

  group('DeleteMotorcycleRepositoryImpl', () {
    const testMotorcycleId = 'test-motorcycle-123';

    group('deleteMotorcycle', () {
      test('should return success message when datasource succeeds', () async {
        // Arrange
        const successMessage = 'Motocicleta eliminada exitosamente';
        when(
          mockDataSource.deleteMotorcycle(testMotorcycleId),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await repository.deleteMotorcycle(testMotorcycleId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(mockDataSource.deleteMotorcycle(testMotorcycleId)).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'ERR_MOTORCYCLE_001',
          message: 'No se puede eliminar la motocicleta',
        );
        when(
          mockDataSource.deleteMotorcycle(testMotorcycleId),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await repository.deleteMotorcycle(testMotorcycleId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockDataSource.deleteMotorcycle(testMotorcycleId)).called(1);
      });

      test('should delegate to datasource with correct ID', () async {
        // Arrange
        const differentId = 'another-motorcycle-uuid';
        when(
          mockDataSource.deleteMotorcycle(differentId),
        ).thenAnswer((_) async => const Right('Deleted'));

        // Act
        await repository.deleteMotorcycle(differentId);

        // Assert
        verify(mockDataSource.deleteMotorcycle(differentId)).called(1);
        verifyNever(mockDataSource.deleteMotorcycle(testMotorcycleId));
      });
    });
  });
}
