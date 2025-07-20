import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/domain/usecases/verify_email_usecase.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/person_entity.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;

  LoginBloc(this.loginUseCase, this.verifyEmailUseCase)
    : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  void _onLoginSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginInProgress());
    final result = await loginUseCase(event.email, event.password);
    await result.fold(
      (error) async {
        if (error.message == '403') {
          final verificationResult = await verifyEmailUseCase(event.email);
          verificationResult.fold(
            (verifyError) => emit(LoginFailure(verifyError)),
            (isVerified) {
              if (isVerified) {
                emit(
                  LoginFailure(
                    ErrorModel(
                      message: 'Usuario verificado pero no encontrado.',
                      isError: true,
                    ),
                  ),
                );
              } else {
                emit(LoginNeedsVerification());
              }
            },
          );
        } else {
          emit(LoginFailure(error));
        }
      },
      (person) async {
        if (person.emailVerified) {
          emit(LoginSuccess(person));
        } else {
          emit(LoginNeedsVerification());
        }
      },
    );
  }
}
