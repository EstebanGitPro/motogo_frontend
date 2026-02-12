import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/login_result.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';

@GenerateMocks([LoginUseCase])
import 'login_bloc_test.mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late LoginBloc bloc;

  const tUser = UserEntity(
    id: 'user-123',
    identityNumber: '1234567890',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    role: 'ADMIN',
  );

  const tLoginResult = LoginResult(
    user: tUser,
    message: 'Login exitoso',
    code: 'AUTH_LOGIN_OK',
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, LoginResult>>(const Right(tLoginResult));
  });

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    bloc = LoginBloc(loginUseCase: mockLoginUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('LoginBloc', () {
    test('initial state should be LoginInitial', () {
      expect(bloc.state, isA<LoginInitial>());
    });

    group('LoginSubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginSuccess] on successful login',
        build: () {
          when(
            mockLoginUseCase.call(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer((_) async => const Right(tLoginResult));
          return bloc;
        },
        act: (bloc) => bloc.add(
          const LoginSubmitted(email: 'juan@test.com', password: 'password123'),
        ),
        expect: () => [
          isA<LoginInProgress>(),
          isA<LoginSuccess>()
              .having((s) => s.user, 'user', tUser)
              .having((s) => s.message, 'message', 'Login exitoso')
              .having((s) => s.code, 'code', 'AUTH_LOGIN_OK'),
        ],
        verify: (_) {
          verify(
            mockLoginUseCase.call(
              email: 'juan@test.com',
              password: 'password123',
            ),
          ).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginFailure] on generic error',
        build: () {
          when(
            mockLoginUseCase.call(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => Left(
              ErrorModel(
                message: 'Credenciales inválidas',
                errorCode: 'INVALID_CREDENTIALS',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const LoginSubmitted(email: 'juan@test.com', password: 'wrong'),
        ),
        expect: () => [
          isA<LoginInProgress>(),
          isA<LoginFailure>().having(
            (s) => s.error.message,
            'message',
            'Credenciales inválidas',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginNeedsVerification] when errorCode is EMAIL_NOT_VERIFIED',
        build: () {
          when(
            mockLoginUseCase.call(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => Left(
              ErrorModel(
                message: 'El email no ha sido verificado',
                errorCode: 'EMAIL_NOT_VERIFIED',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const LoginSubmitted(email: 'juan@test.com', password: 'pass'),
        ),
        expect: () => [
          isA<LoginInProgress>(),
          isA<LoginNeedsVerification>().having(
            (s) => s.message,
            'message',
            'El email no ha sido verificado',
          ),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginNeedsVerification] when errorCode is UNVERIFIED_EMAIL',
        build: () {
          when(
            mockLoginUseCase.call(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => Left(
              ErrorModel(
                message: 'Email not verified',
                errorCode: 'UNVERIFIED_EMAIL',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const LoginSubmitted(email: 'test@test.com', password: 'pass'),
        ),
        expect: () => [isA<LoginInProgress>(), isA<LoginNeedsVerification>()],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginNeedsVerification] when errorCode is 403',
        build: () {
          when(
            mockLoginUseCase.call(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async =>
                Left(ErrorModel(message: 'Forbidden', errorCode: '403')),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const LoginSubmitted(email: 'test@test.com', password: 'pass'),
        ),
        expect: () => [isA<LoginInProgress>(), isA<LoginNeedsVerification>()],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginInProgress, LoginNeedsVerification] when message contains verificar keyword',
        build: () {
          when(
            mockLoginUseCase.call(
              email: anyNamed('email'),
              password: anyNamed('password'),
            ),
          ).thenAnswer(
            (_) async => Left(
              ErrorModel(
                message: 'Debes verificar tu email primero',
                errorCode: 'SOME_CODE',
              ),
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(
          const LoginSubmitted(email: 'test@test.com', password: 'pass'),
        ),
        expect: () => [isA<LoginInProgress>(), isA<LoginNeedsVerification>()],
      );
    });

    group('LoginEvent props', () {
      test('LoginSubmitted props should include email and password', () {
        const event = LoginSubmitted(email: 'a@b.com', password: '123');
        expect(event.props, ['a@b.com', '123']);
      });

      test('LoginLogout props should be empty', () {
        final event = LoginLogout();
        expect(event.props, isEmpty);
      });
    });

    group('LoginState props', () {
      test('LoginInitial props should be empty', () {
        expect(LoginInitial().props, isEmpty);
      });

      test('LoginSuccess props should include user, message, code', () {
        const state = LoginSuccess(user: tUser, message: 'OK', code: 'CODE');
        expect(state.props, [tUser, 'OK', 'CODE']);
      });

      test('LoginFailure props should include error', () {
        final error = ErrorModel(message: 'fail');
        final state = LoginFailure(error: error);
        expect(state.props, [error]);
      });

      test('LoginNeedsVerification props should include message', () {
        const state = LoginNeedsVerification(message: 'verify');
        expect(state.props, ['verify']);
      });

      test('LoginNeedsVerification props should handle null message', () {
        const state = LoginNeedsVerification();
        expect(state.props, ['']);
      });

      test('LoginLoggedOut props should be empty', () {
        expect(LoginLoggedOut().props, isEmpty);
      });

      test('LoginInProgress props should be empty', () {
        expect(LoginInProgress().props, isEmpty);
      });
    });
  });
}
