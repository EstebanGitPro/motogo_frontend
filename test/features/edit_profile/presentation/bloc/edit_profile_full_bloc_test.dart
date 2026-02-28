import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/get_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/update_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';

import 'edit_profile_full_bloc_test.mocks.dart';

@GenerateMocks([GetPersonUsecase, UpdatePersonUsecase])
void main() {
  late MockGetPersonUsecase mockGetPerson;
  late MockUpdatePersonUsecase mockUpdatePerson;

  const testUser = UserEntity(
    id: 'u-1',
    identityNumber: '123456',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    role: 'CUSTOMER',
  );

  const updatedUser = UserEntity(
    id: 'u-1',
    identityNumber: '123456',
    firstName: 'Juan Carlos',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3009999999',
    role: 'CUSTOMER',
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, UserEntity>>(const Right(testUser));
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockGetPerson = MockGetPersonUsecase();
    mockUpdatePerson = MockUpdatePersonUsecase();
  });

  EditProfileBloc buildBloc() => EditProfileBloc(
    getPersonUsecase: mockGetPerson,
    updatePersonUsecase: mockUpdatePerson,
  );

  group('EditProfileBloc', () {
    test('initial state has initial status', () {
      final bloc = buildBloc();
      expect(bloc.state.status, EditProfileStatus.initial);
    });

    blocTest<EditProfileBloc, EditProfileState>(
      'emits [loading, success] on load from server',
      setUp: () {
        when(
          mockGetPerson.call(),
        ).thenAnswer((_) async => const Right(testUser));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(EditProfileLoaded(forceRefresh: true)),
      expect: () => [
        isA<EditProfileState>().having(
          (s) => s.status,
          'status',
          EditProfileStatus.loading,
        ),
        isA<EditProfileState>()
            .having((s) => s.status, 'status', EditProfileStatus.success)
            .having((s) => s.user?.firstName, 'firstName', 'Juan'),
      ],
    );

    blocTest<EditProfileBloc, EditProfileState>(
      'emits [loading, failure] on load error without cache',
      setUp: () {
        when(
          mockGetPerson.call(),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Sin conexión')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(EditProfileLoaded(forceRefresh: true)),
      expect: () => [
        isA<EditProfileState>().having(
          (s) => s.status,
          'status',
          EditProfileStatus.loading,
        ),
        isA<EditProfileState>().having(
          (s) => s.status,
          'status',
          EditProfileStatus.failure,
        ),
      ],
    );

    blocTest<EditProfileBloc, EditProfileState>(
      'emits [loading, success] on save success',
      setUp: () {
        when(
          mockUpdatePerson.call(updatedUser),
        ).thenAnswer((_) async => const Right('Perfil actualizado'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(EditProfileSaved(updatedUser)),
      expect: () => [
        isA<EditProfileState>().having(
          (s) => s.status,
          'status',
          EditProfileStatus.loading,
        ),
        isA<EditProfileState>()
            .having((s) => s.status, 'status', EditProfileStatus.success)
            .having(
              (s) => s.successMessage,
              'successMessage',
              'Perfil actualizado',
            )
            .having((s) => s.user?.firstName, 'firstName', 'Juan Carlos'),
      ],
    );

    blocTest<EditProfileBloc, EditProfileState>(
      'emits [loading, failure] on save error',
      setUp: () {
        when(
          mockUpdatePerson.call(updatedUser),
        ).thenAnswer((_) async => Left(ErrorModel(message: 'Error')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(EditProfileSaved(updatedUser)),
      expect: () => [
        isA<EditProfileState>().having(
          (s) => s.status,
          'status',
          EditProfileStatus.loading,
        ),
        isA<EditProfileState>().having(
          (s) => s.status,
          'status',
          EditProfileStatus.failure,
        ),
      ],
    );

    blocTest<EditProfileBloc, EditProfileState>(
      'emits reset state on EditProfileReset',
      build: buildBloc,
      act: (bloc) => bloc.add(EditProfileReset()),
      expect: () => [
        isA<EditProfileState>().having(
          (s) => s.status,
          'status',
          EditProfileStatus.initial,
        ),
      ],
    );
  });
}
