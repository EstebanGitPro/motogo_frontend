import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/repositories/delete_branch_repository.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/usecases/delete_branch_usecase.dart';

import 'delete_branch_usecase_test.mocks.dart';

@GenerateMocks([DeleteBranchRepository])
void main() {
  late DeleteBranchUseCase useCase;
  late MockDeleteBranchRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockDeleteBranchRepository();
    useCase = DeleteBranchUseCase(mockRepository);
  });

  group('DeleteBranchUseCase', () {
    const testBranchId = 'test-branch-123';

    group('call', () {
      test('should return success message when repository succeeds', () async {
        // Arrange
        const successMessage = 'Sede eliminada exitosamente';
        when(
          mockRepository.deleteBranch(testBranchId),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await useCase.call(testBranchId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(mockRepository.deleteBranch(testBranchId)).called(1);
      });

      test('should return ErrorModel when repository fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'ERR_BRANCH_001',
          message: 'No se puede eliminar la sede',
        );
        when(
          mockRepository.deleteBranch(testBranchId),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await useCase.call(testBranchId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockRepository.deleteBranch(testBranchId)).called(1);
      });

      test('should delegate to repository with correct ID', () async {
        // Arrange
        const differentId = 'another-branch-uuid';
        when(
          mockRepository.deleteBranch(differentId),
        ).thenAnswer((_) async => const Right('Deleted'));

        // Act
        await useCase.call(differentId);

        // Assert
        verify(mockRepository.deleteBranch(differentId)).called(1);
        verifyNever(mockRepository.deleteBranch(testBranchId));
      });

      test('should be callable with call syntax', () async {
        // Arrange
        when(
          mockRepository.deleteBranch(testBranchId),
        ).thenAnswer((_) async => const Right('Success'));

        // Act - using call() syntax
        final result = await useCase(testBranchId);

        // Assert
        expect(result.isRight, isTrue);
      });
    });
  });
}
