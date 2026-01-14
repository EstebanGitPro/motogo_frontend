import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_person/data/datasources/delete_person_data_source.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/repositories/delete_person_repository.dart';

import 'delete_person_repository_test.mocks.dart';

@GenerateMocks([DeletePersonDataSource])
void main() {
  late DeletePersonRepositoryImpl repository;
  late MockDeletePersonDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockDeletePersonDataSource();
    repository = DeletePersonRepositoryImpl(mockDataSource);
  });

  group('DeletePersonRepositoryImpl', () {
    group('deleteAccount', () {
      test('should return success message when datasource succeeds', () async {
        // Arrange
        const successMessage = 'Usuario eliminado exitosamente';
        when(
          mockDataSource.deleteAccount(),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await repository.deleteAccount();

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(mockDataSource.deleteAccount()).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final error = ErrorModel(message: 'Error al eliminar cuenta');
        when(
          mockDataSource.deleteAccount(),
        ).thenAnswer((_) async => Left(error));

        // Act
        final result = await repository.deleteAccount();

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error al eliminar cuenta');
        verify(mockDataSource.deleteAccount()).called(1);
      });
    });
  });
}
