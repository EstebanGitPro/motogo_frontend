import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/reset_password_usecase.dart';

part 'password_recovery_event.dart';
part 'password_recovery_state.dart';

class PasswordRecoveryBloc
    extends Bloc<PasswordResetEvent, PasswordResetState> {
  PasswordRecoveryBloc() : super(PasswordResetInitial()) {
    final PasswordResetUseCase resetPasswordUseCase =
        InjectorApp.resolve<PasswordResetUseCase>();

    on<ResetPasswordSubmitted>(
      (event, emit) =>
          _onResetPasswordSubmitted(event, emit, resetPasswordUseCase),
    );
  }

  Future<void> _onResetPasswordSubmitted(
    ResetPasswordSubmitted event,
    Emitter<PasswordResetState> emit,
    PasswordResetUseCase resetPasswordUseCase,
  ) async {
    emit(PasswordResetLoading());

    final result = await resetPasswordUseCase.call(
      event.code,
      event.newPassword,
    );

    result.fold(
      (failure) => emit(PasswordResetFailure(failure)),
      (_) => emit(PasswordResetSuccess()),
    );
  }
}
