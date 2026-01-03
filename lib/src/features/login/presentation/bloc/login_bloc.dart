import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/constants/login_constants.dart';
import 'package:motogo_frontend/src/features/login/domain/entities/person_login_entity.dart';

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

        // DEBUG: Ver qué error está llegando
        debugPrint('🔴 LOGIN ERROR:');
        debugPrint('  Message: ${failure.message}');
        debugPrint('  ErrorCode: ${failure.errorCode}');
        debugPrint('  StatusCode: ${failure.statusCode}');

        // Check both errorCode and message for email verification
        final messageLower = failure.message.toLowerCase();
        final needsVerification =
            failure.errorCode == LoginErrorConstants.emailNotVerifiedCode ||
            failure.errorCode == LoginErrorConstants.unverifiedEmailCode ||
            failure.errorCode == LoginErrorConstants.forbiddenCode ||
            LoginErrorConstants.verificationKeywords.any(
              (keyword) => messageLower.contains(keyword),
            );

        debugPrint('  NeedsVerification: $needsVerification');

        if (needsVerification) {
          emit(LoginNeedsVerification(message: failure.message));
        } else {
          emit(LoginFailure(error: failure));
        }
      } else {
        final user = result.right;
        await _saveUserData(user);
        emit(LoginSuccess(user: user));
      }
    } catch (e) {
      emit(LoginFailure(error: ErrorModel(message: 'Error inesperado: $e')));
    }
  }

  Future<void> _onLogout(LoginLogout event, Emitter<LoginState> emit) async {
    try {
      emit(LoginInProgress());
      await _clearUserData();
      emit(LoginLoggedOut());
    } catch (e) {
      emit(
        LoginFailure(error: ErrorModel(message: 'Error al cerrar sesión: $e')),
      );
    }
  }

  Future<void> _saveUserData(PersonEntity user) async {
    try {
      final secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'user_id', value: user.id);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  Future<void> _clearUserData() async {
    final secureStorage = FlutterSecureStorage();
    await secureStorage.delete(key: 'user_id');
  }
}
