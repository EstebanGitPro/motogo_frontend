import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_branch/domain/usecases/update_branch_usecase.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';

import 'update_branch_usecase_test.mocks.dart';

@GenerateMocks([BranchRepository])
void main() {
  late UpdateBranchUseCase useCase;
  late MockBranchRepository mockRepository;

  final testBranch = BranchEntity(
    id: 'branch-1',
    name: 'MotoGo Centro',
    establishmentType: 'WORKSHOP',
    location: const BranchLocation(
      address: 'Calle 50 #30-40',
      cityId: 'city-1',
      departmentId: 'dept-1',
    ),
  );
  final errorModel = ErrorModel(message: 'Error', errorCode: 'ERR');

  setUpAll(() {
    provideDummy<Either<ErrorModel, (BranchEntity, String)>>(
      Right((testBranch, 'Sede actualizada exitosamente')),
    );
  });

  setUp(() {
    mockRepository = MockBranchRepository();
    useCase = UpdateBranchUseCase(mockRepository);
  });

  group('UpdateBranchUseCase', () {
    test('should return updated BranchEntity and message on success', () async {
      when(mockRepository.updateBranch('branch-1', testBranch)).thenAnswer(
        (_) async => Right((testBranch, 'Sede actualizada exitosamente')),
      );

      final result = await useCase.call('branch-1', testBranch);

      expect(result.isRight, isTrue);
      final (branch, message) = result.right;
      expect(branch.name, 'MotoGo Centro');
      expect(message, 'Sede actualizada exitosamente');
      verify(mockRepository.updateBranch('branch-1', testBranch)).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.updateBranch('branch-1', testBranch),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call('branch-1', testBranch);

      expect(result.isLeft, isTrue);
      expect(result.left, errorModel);
    });
  });
}
