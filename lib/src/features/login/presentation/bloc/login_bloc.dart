import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/constants/login_constants.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';

import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/login/domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    final LoginUseCase loginUseCase = InjectorApp.resolve<LoginUseCase>();
    on<LoginSubmitted>(
      (event, emit) => _onLoginSubmitted(event, emit, loginUseCase),
    );
    on<LoginLogout>(_onLogout);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
    LoginUseCase loginUsecase,
  ) async {
    emit(LoginInProgress());

    try {
      final result = await loginUsecase.call(
        email: event.email,
        password: event.password,
      );

      if (result.isLeft) {
        final failure = result.left;

        // Check both errorCode and message for email verification
        final messageLower = failure.message.toLowerCase();
        final needsVerification =
            failure.errorCode == LoginErrorConstants.emailNotVerifiedCode ||
            failure.errorCode == LoginErrorConstants.unverifiedEmailCode ||
            failure.errorCode == LoginErrorConstants.forbiddenCode ||
            LoginErrorConstants.verificationKeywords.any(
              (keyword) => messageLower.contains(keyword),
            );

        if (needsVerification) {
          emit(LoginNeedsVerification(message: failure.message));
        } else {
          emit(LoginFailure(error: failure));
        }
      } else {
        final loginResult = result.right;

        // Emitir éxito con el mensaje del backend
        emit(
          LoginSuccess(
            user: loginResult.user,
            message: loginResult.message,
            code: loginResult.code,
          ),
        );
      }
    } catch (e) {
      emit(LoginFailure(error: ErrorModel(message: 'Error inesperado: $e')));
    }
  }

  Future<void> _onLogout(LoginLogout event, Emitter<LoginState> emit) async {
    try {
      emit(LoginInProgress());
      // Usar UserSessionManager para limpiar la sesión
      await UserSessionManager.instance.clearSession();
      emit(LoginLoggedOut());
    } catch (e) {
      emit(
        LoginFailure(error: ErrorModel(message: 'Error al cerrar sesión: $e')),
      );
    }
  }
}
