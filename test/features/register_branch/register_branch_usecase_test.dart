import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/repositories/branch_repository.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/usecases/register_branch_usecase.dart';

import 'register_branch_usecase_test.mocks.dart';

@GenerateMocks([BranchRepository])
void main() {
  late RegisterBranchUseCase useCase;
  late MockBranchRepository mockRepository;

  final testBranch = BranchEntity(
    name: 'MotoGo Norte',
    establishmentType: 'WORKSHOP',
    location: const BranchLocation(
      address: 'Cra 7 #100-10',
      cityId: 'city-1',
      departmentId: 'dept-1',
    ),
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockBranchRepository();
    useCase = RegisterBranchUseCase(mockRepository);
  });

  group('RegisterBranchUseCase', () {
    test('should return success message on success', () async {
      when(
        mockRepository.registerBranch(testBranch),
      ).thenAnswer((_) async => const Right('Sede registrada'));

      final result = await useCase.call(testBranch);

      expect(result.isRight, isTrue);
      expect(result.right, 'Sede registrada');
      verify(mockRepository.registerBranch(testBranch)).called(1);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Error', errorCode: 'ERR');
      when(
        mockRepository.registerBranch(testBranch),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call(testBranch);

      expect(result.isLeft, isTrue);
      expect(result.left, error);
    });
  });
}
