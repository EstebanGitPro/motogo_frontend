import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/domain/usecases/update_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/presentation/bloc/edit_motorcycle_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

import 'edit_motorcycle_bloc_test.mocks.dart';

@GenerateMocks([UpdateMotorcycleUseCase])
void main() {
  late MockUpdateMotorcycleUseCase mockUseCase;

  const testMotorcycle = MotorcycleEntity(
    licensePlate: 'ABC123',
    referenceId: 'ref-1',
    year: 2024,
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockUseCase = MockUpdateMotorcycleUseCase();
  });

  group('EditMotorcycleBloc', () {
    test('initial state is EditMotorcycleInitial', () {
      final bloc = EditMotorcycleBloc(updateMotorcycleUseCase: mockUseCase);
      expect(bloc.state, isA<EditMotorcycleInitial>());
    });

    blocTest<EditMotorcycleBloc, EditMotorcycleState>(
      'emits [Saving, Success] on successful update',
      setUp: () {
        when(
          mockUseCase.call('moto-1', testMotorcycle),
        ).thenAnswer((_) async => const Right('Moto actualizada'));
      },
      build: () => EditMotorcycleBloc(updateMotorcycleUseCase: mockUseCase),
      act: (bloc) => bloc.add(
        const UpdateMotorcycle(id: 'moto-1', motorcycle: testMotorcycle),
      ),
      expect: () => [
        isA<EditMotorcycleSaving>(),
        isA<EditMotorcycleSuccess>().having(
          (s) => s.message,
          'message',
          'Moto actualizada',
        ),
      ],
    );

    blocTest<EditMotorcycleBloc, EditMotorcycleState>(
      'emits [Saving, Error] on failure',
      setUp: () {
        when(mockUseCase.call('moto-1', testMotorcycle)).thenAnswer(
          (_) async => Left(ErrorModel(message: 'Error al actualizar')),
        );
      },
      build: () => EditMotorcycleBloc(updateMotorcycleUseCase: mockUseCase),
      act: (bloc) => bloc.add(
        const UpdateMotorcycle(id: 'moto-1', motorcycle: testMotorcycle),
      ),
      expect: () => [
        isA<EditMotorcycleSaving>(),
        isA<EditMotorcycleError>().having(
          (s) => s.message,
          'message',
          'Error al actualizar',
        ),
      ],
    );
  });
}
