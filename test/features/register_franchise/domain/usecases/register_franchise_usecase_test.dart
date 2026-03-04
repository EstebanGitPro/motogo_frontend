import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/repositories/franchise_repository.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/usecases/register_franchise_usecase.dart';

@GenerateMocks([FranchiseRepository])
import 'register_franchise_usecase_test.mocks.dart';

void main() {
  late MockFranchiseRepository mockRepository;
  late RegisterFranchiseUseCase useCase;

  const tFranchise = FranchiseEntity(
    name: 'MotoRed',
    description: 'Red de talleres',
    branchIds: ['branch-1', 'branch-2'],
  );

  const tResult = FranchiseEntity(
    id: 'franchise-abc',
    name: 'MotoRed',
    description: 'Red de talleres',
    branchIds: ['branch-1', 'branch-2'],
  );

  const tMessage = 'Franquicia creada exitosamente';

  setUpAll(() {
    provideDummy<Either<ErrorModel, (FranchiseEntity, String)>>(
      const Right((tFranchise, tMessage)),
    );
  });

  setUp(() {
    mockRepository = MockFranchiseRepository();
    useCase = RegisterFranchiseUseCase(mockRepository);
  });

  group('RegisterFranchiseUseCase', () {
    test('should return error when branchIds is empty', () async {
      const emptyFranchise = FranchiseEntity(name: 'Empty', branchIds: []);

      final result = await useCase.call(emptyFranchise);

      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Debes seleccionar al menos una sede');
      verifyZeroInteractions(mockRepository);
    });

    test('should delegate to repository when branchIds is not empty', () async {
      when(
        mockRepository.registerFranchise(any),
      ).thenAnswer((_) async => const Right((tResult, tMessage)));

      final result = await useCase.call(tFranchise);

      expect(result.isRight, isTrue);
      final (entity, message) = result.right;
      expect(entity.id, 'franchise-abc');
      expect(message, tMessage);
      verify(mockRepository.registerFranchise(tFranchise)).called(1);
    });

    test('should return error from repository', () async {
      when(
        mockRepository.registerFranchise(any),
      ).thenAnswer((_) async => Left(ErrorModel(message: 'Server error')));

      final result = await useCase.call(tFranchise);

      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Server error');
    });
  });
}
