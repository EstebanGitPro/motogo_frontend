import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/verify_email_usecase.dart';

part 'email_verification_event.dart';
part 'email_verification_state.dart';

class EmailRecoveryVerificationBloc
    extends
        Bloc<EmailRecoveryVerificationEvent, EmailRecoveryVerificationState> {
  EmailRecoveryVerificationBloc()
    : super(const EmailRecoveryVerificationInitial()) {
    final VerifyRecoveryEmailUseCase verifyEmailUseCase =
        InjectorApp.resolve<VerifyRecoveryEmailUseCase>();

    on<EmailRecoveryVerificationSubmitted>(
      (event, emit) => _onSubmitted(event, emit, verifyEmailUseCase),
    );
  }

  Future<void> _onSubmitted(
    EmailRecoveryVerificationSubmitted event,
    Emitter<EmailRecoveryVerificationState> emit,
    VerifyRecoveryEmailUseCase useCase,
  ) async {
    emit(const EmailRecoveryVerificationLoading());

    final result = await useCase.call(event.email);

    result.fold(
      (failure) => emit(EmailRecoveryVerificationFailure(failure)),
      (_) => emit(const EmailRecoveryVerificationSuccess()),
    );
  }
}
