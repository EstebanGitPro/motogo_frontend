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
        if (error.errorCode == '403') {
          emit(LoginNeedsVerification(message: error.message));
        } else if (error.errorCode == '401') {
          emit(LoginFailure(error));
        } else if (error.errorCode == '400') {
          emit(LoginFailure(error));
        } else {
          emit(LoginFailure(error));
        }
      },
      (person) async {
        emit(LoginSuccess(person));
      },
    );
  }
}
