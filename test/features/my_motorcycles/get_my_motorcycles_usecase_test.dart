import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/repositories/my_motorcycles_repository.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/usecases/get_my_motorcycles_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

import 'get_my_motorcycles_usecase_test.mocks.dart';

@GenerateMocks([MyMotorcyclesRepository])
void main() {
  late GetMyMotorcyclesUseCase useCase;
  late MockMyMotorcyclesRepository mockRepository;

  const testMotorcycle = MotorcycleEntity(
    id: 'moto-1',
    licensePlate: 'ABC12D',
    year: 2024,
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<MotorcycleEntity>>>(const Right([]));
  });

  setUp(() {
    mockRepository = MockMyMotorcyclesRepository();
    useCase = GetMyMotorcyclesUseCase(mockRepository);
  });

  group('GetMyMotorcyclesUseCase', () {
    test('should return list of motorcycles on success', () async {
      when(
        mockRepository.getMotorcycles(),
      ).thenAnswer((_) async => const Right([testMotorcycle]));

      final result = await useCase.call();

      expect(result.isRight, isTrue);
      expect(result.right.length, 1);
      expect(result.right.first.licensePlate, 'ABC12D');
      verify(mockRepository.getMotorcycles()).called(1);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Error', errorCode: 'ERR');
      when(
        mockRepository.getMotorcycles(),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call();

      expect(result.isLeft, isTrue);
      expect(result.left, error);
    });
  });
}
