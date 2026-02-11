import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/change_password/domain/usecases/change_password_usecase.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/bloc/change_password_bloc.dart';

@GenerateMocks([ChangePasswordUseCase])
import 'change_password_bloc_test.mocks.dart';

void main() {
  late MockChangePasswordUseCase mockUseCase;
  late ChangePasswordBloc bloc;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockUseCase = MockChangePasswordUseCase();
    bloc = ChangePasswordBloc(changePasswordUseCase: mockUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('ChangePasswordBloc', () {
    test('initial state should be ChangePasswordInitial', () {
      expect(bloc.state, isA<ChangePasswordInitial>());
    });

    blocTest<ChangePasswordBloc, ChangePasswordState>(
      'emits [Loading, Success] on successful password change',
      build: () {
        when(
          mockUseCase.call(
            currentPassword: anyNamed('currentPassword'),
            newPassword: anyNamed('newPassword'),
          ),
        ).thenAnswer((_) async => const Right('Contraseña actualizada'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        ChangePasswordSubmitted(
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
        ),
      ),
      expect: () => [
        isA<ChangePasswordLoading>(),
        isA<ChangePasswordSuccess>().having(
          (s) => s.message,
          'message',
          'Contraseña actualizada',
        ),
      ],
      verify: (_) {
        verify(
          mockUseCase.call(
            currentPassword: 'oldPass123',
            newPassword: 'newPass456',
          ),
        ).called(1);
      },
    );

    blocTest<ChangePasswordBloc, ChangePasswordState>(
      'emits [Loading, Error] on failed password change',
      build: () {
        when(
          mockUseCase.call(
            currentPassword: anyNamed('currentPassword'),
            newPassword: anyNamed('newPassword'),
          ),
        ).thenAnswer(
          (_) async =>
              Left(ErrorModel(message: 'Contraseña actual incorrecta')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        ChangePasswordSubmitted(
          currentPassword: 'wrongPass',
          newPassword: 'newPass456',
        ),
      ),
      expect: () => [
        isA<ChangePasswordLoading>(),
        isA<ChangePasswordError>().having(
          (s) => s.message,
          'message',
          'Contraseña actual incorrecta',
        ),
      ],
    );

    group('ChangePasswordEvent', () {
      test('ChangePasswordSubmitted should have correct fields', () {
        final event = ChangePasswordSubmitted(
          currentPassword: 'old',
          newPassword: 'new',
        );
        expect(event.currentPassword, 'old');
        expect(event.newPassword, 'new');
      });
    });

    group('ChangePasswordState', () {
      test('ChangePasswordSuccess should have message field', () {
        final state = ChangePasswordSuccess(message: 'OK');
        expect(state.message, 'OK');
      });

      test('ChangePasswordError should have message field', () {
        final state = ChangePasswordError(message: 'Error');
        expect(state.message, 'Error');
      });
    });
  });
}
