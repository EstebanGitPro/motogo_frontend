import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/data/datasources/edit_motorcycle_datasource.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/domain/usecases/update_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

import 'update_motorcycle_usecase_test.mocks.dart';

@GenerateMocks([EditMotorcycleDataSource])
void main() {
  late UpdateMotorcycleUseCase useCase;
  late MockEditMotorcycleDataSource mockDataSource;

  const testMotorcycle = MotorcycleEntity(
    id: 'moto-1',
    licensePlate: 'ABC12D',
    referenceId: 'ref-1',
    year: 2024,
    currentMileage: 5000,
    ownerNotes: 'Mi moto favorita',
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockEditMotorcycleDataSource();
    useCase = UpdateMotorcycleUseCase(mockDataSource);
  });

  group('UpdateMotorcycleUseCase', () {
    test('should convert entity to model and delegate to datasource', () async {
      when(
        mockDataSource.updateMotorcycle('moto-1', any),
      ).thenAnswer((_) async => const Right('Motocicleta actualizada'));

      final result = await useCase.call('moto-1', testMotorcycle);

      expect(result.isRight, isTrue);
      expect(result.right, 'Motocicleta actualizada');
      verify(mockDataSource.updateMotorcycle('moto-1', any)).called(1);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Error', errorCode: 'ERR');
      when(
        mockDataSource.updateMotorcycle('moto-1', any),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call('moto-1', testMotorcycle);

      expect(result.isLeft, isTrue);
      expect(result.left, error);
    });
  });
}
