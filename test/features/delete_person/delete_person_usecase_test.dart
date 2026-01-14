import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:either_dart/either.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/repositories/delete_person_repository.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/usecases/delete_person_usecase.dart';

import 'delete_person_usecase_test.mocks.dart';

@GenerateMocks([DeletePersonRepository])
void main() {
  late DeletePersonUseCase useCase;
  late MockDeletePersonRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockDeletePersonRepository();
    useCase = DeletePersonUseCase(mockRepository);
  });

  group('DeletePersonUseCase', () {
    test('should return success message when repository succeeds', () async {
      // Arrange
      const successMessage = 'Tu cuenta ha sido eliminada exitosamente';
      when(
        mockRepository.deleteAccount(),
      ).thenAnswer((_) async => const Right(successMessage));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight, isTrue);
      expect(result.right, successMessage);
      verify(mockRepository.deleteAccount()).called(1);
    });

    test('should return ErrorModel when repository fails', () async {
      // Arrange
      final error = ErrorModel(
        message: 'No se puede eliminar: tienes sedes activas',
      );
      when(mockRepository.deleteAccount()).thenAnswer((_) async => Left(error));

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft, isTrue);
      expect(result.left.message, 'No se puede eliminar: tienes sedes activas');
      verify(mockRepository.deleteAccount()).called(1);
    });
  });
}
