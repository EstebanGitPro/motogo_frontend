import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/delete_branch/data/datasources/delete_branch_data_source.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/repositories/delete_branch_repository.dart';

import 'delete_branch_repository_test.mocks.dart';

@GenerateMocks([DeleteBranchDataSource])
void main() {
  late DeleteBranchRepositoryImpl repository;
  late MockDeleteBranchDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockDeleteBranchDataSource();
    repository = DeleteBranchRepositoryImpl(mockDataSource);
  });

  group('DeleteBranchRepositoryImpl', () {
    const testBranchId = 'test-branch-123';

    group('deleteBranch', () {
      test('should return success message when datasource succeeds', () async {
        // Arrange
        const successMessage = 'Sede eliminada exitosamente';
        when(
          mockDataSource.deleteBranch(testBranchId),
        ).thenAnswer((_) async => const Right(successMessage));

        // Act
        final result = await repository.deleteBranch(testBranchId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, successMessage);
        verify(mockDataSource.deleteBranch(testBranchId)).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'ERR_BRANCH_001',
          message: 'No se puede eliminar la sede',
        );
        when(
          mockDataSource.deleteBranch(testBranchId),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await repository.deleteBranch(testBranchId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockDataSource.deleteBranch(testBranchId)).called(1);
      });

      test('should delegate to datasource with correct ID', () async {
        // Arrange
        const differentId = 'another-branch-uuid';
        when(
          mockDataSource.deleteBranch(differentId),
        ).thenAnswer((_) async => const Right('Deleted'));

        // Act
        await repository.deleteBranch(differentId);

        // Assert
        verify(mockDataSource.deleteBranch(differentId)).called(1);
        verifyNever(mockDataSource.deleteBranch(testBranchId));
      });
    });
  });
}
