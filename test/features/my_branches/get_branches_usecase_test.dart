import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/repositories/my_branches_repository.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

import 'get_branches_usecase_test.mocks.dart';

@GenerateMocks([MyBranchesRepository])
void main() {
  late GetBranchesUseCase useCase;
  late MockMyBranchesRepository mockRepository;

  final testBranch = BranchEntity(
    id: 'branch-1',
    name: 'MotoGo Centro',
    establishmentType: 'WORKSHOP',
    location: const BranchLocation(
      address: 'Calle 50',
      cityId: 'city-1',
      departmentId: 'dept-1',
    ),
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<BranchEntity>>>(const Right([]));
  });

  setUp(() {
    mockRepository = MockMyBranchesRepository();
    useCase = GetBranchesUseCase(mockRepository);
  });

  group('GetBranchesUseCase', () {
    test('should return list of branches on success', () async {
      when(
        mockRepository.getBranches(),
      ).thenAnswer((_) async => Right([testBranch]));

      final result = await useCase.call();

      expect(result.isRight, isTrue);
      expect(result.right.length, 1);
      expect(result.right.first.name, 'MotoGo Centro');
      verify(mockRepository.getBranches()).called(1);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Error', errorCode: 'ERR');
      when(mockRepository.getBranches()).thenAnswer((_) async => Left(error));

      final result = await useCase.call();

      expect(result.isLeft, isTrue);
      expect(result.left, error);
    });
  });
}
