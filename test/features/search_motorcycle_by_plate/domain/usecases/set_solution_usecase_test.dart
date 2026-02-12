import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/repositories/search_motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/usecases/set_solution_usecase.dart';

import 'set_solution_usecase_test.mocks.dart';

@GenerateMocks([SearchMotorcycleRepository])
void main() {
  late SetSolutionUseCase useCase;
  late MockSearchMotorcycleRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockSearchMotorcycleRepository();
    useCase = SetSolutionUseCase(mockRepository);
  });

  group('SetSolutionUseCase', () {
    const testDiagnosticId = 'diag-123';
    const testSolution = 'Cambiar filtro de aceite';

    group('call', () {
      test('should return success message when repository succeeds', () async {
        // Arrange
        const successMessage = 'Solución registrada exitosamente';
        when(
          mockRepository.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await useCase.call(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(
          mockRepository.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        ).called(1);
      });

      test('should return ErrorModel when repository fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'ERR_SOLUTION',
          message: 'Error al registrar solución',
        );
        when(
          mockRepository.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await useCase.call(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
      });

      test('should delegate to repository with correct params', () async {
        // Arrange
        const otherId = 'diag-other';
        const otherSolution = 'Otra solución';
        when(
          mockRepository.setSolution(
            diagnosticId: otherId,
            solution: otherSolution,
          ),
        ).thenAnswer((_) async => const Right('OK'));

        // Act
        await useCase.call(diagnosticId: otherId, solution: otherSolution);

        // Assert
        verify(
          mockRepository.setSolution(
            diagnosticId: otherId,
            solution: otherSolution,
          ),
        ).called(1);
        verifyNever(
          mockRepository.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        );
      });

      test('should be callable with call syntax', () async {
        // Arrange
        when(
          mockRepository.setSolution(
            diagnosticId: testDiagnosticId,
            solution: testSolution,
          ),
        ).thenAnswer((_) async => const Right('OK'));

        // Act — using call() syntax
        final result = await useCase(
          diagnosticId: testDiagnosticId,
          solution: testSolution,
        );

        // Assert
        expect(result.isRight, isTrue);
      });
    });
  });
}
