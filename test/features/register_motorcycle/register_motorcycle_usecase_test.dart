import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/repositories/motorcycle_repository.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/usecases/register_motorcycle_usecase.dart';

import 'register_motorcycle_usecase_test.mocks.dart';

@GenerateMocks([MotorcycleRepository])
void main() {
  late RegisterMotorcycleUseCase useCase;
  late MockMotorcycleRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockMotorcycleRepository();
    useCase = RegisterMotorcycleUseCase(mockRepository);
  });

  group('RegisterMotorcycleUseCase', () {
    test(
      'should create entity from params and delegate to repository',
      () async {
        when(
          mockRepository.registerMotorcycle(any),
        ).thenAnswer((_) async => const Right('Motocicleta registrada'));

        final result = await useCase.call(
          licensePlate: 'ABC12D',
          referenceId: 'ref-1',
          year: 2024,
          currentMileage: 5000,
          ownerNotes: 'Mi moto',
          profileImageUrl: 'https://img.com/photo.jpg',
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Motocicleta registrada');
        verify(mockRepository.registerMotorcycle(any)).called(1);
      },
    );

    test('should work with only required params', () async {
      when(
        mockRepository.registerMotorcycle(any),
      ).thenAnswer((_) async => const Right('Registrada'));

      final result = await useCase.call(licensePlate: 'XYZ789');

      expect(result.isRight, isTrue);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Placa duplicada', errorCode: 'DUP');
      when(
        mockRepository.registerMotorcycle(any),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call(licensePlate: 'ABC12D');

      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Placa duplicada');
    });
  });
}
