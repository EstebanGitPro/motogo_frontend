import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/domain/usecases/verify_email_usecase.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/register/domain/entities/person_entity.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'package:motogo_frontend/src/features/register/domain/usecases/register_usecase.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    final registerUseCase = InjectorApp.resolve<RegisterUseCase>();
    final verifyEmailUseCase = InjectorApp.resolve<VerifyEmailUseCase>();

    on<RegisterSubmitted>(
      (event, emit) => _onRegisterSubmitted(event, emit, registerUseCase),
    );

    on<StartVerification>(
      (event, emit) => _onStartVerification(event, emit, verifyEmailUseCase),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
    RegisterUseCase registerUseCase,
  ) async {
    emit(RegisterLoading());
    try {
      final result = await registerUseCase(
        event.identityNumber,
        event.firstName,
        event.lastName,
        event.secondLastName,
        event.email,
        event.phoneNumber,
        event.password,
        event.role,
      );

      result.fold(
        (error) => emit(
          RegisterFailure(
            errorModel: ErrorModel(
              message: ErrorMessageMapper.mapServerError(error.message),
            ),
          ),
        ),
        // CORRECCIÓN: Pasar el email del evento, no una cadena vacía
        (person) => emit(RegisterSuccess(
          result: person, 
          email: event.email, // ← Aquí estaba el error
        )),
      );
    } catch (error) {
      emit(
        RegisterFailure(
          errorModel: ErrorModel(message: error.toString(), isError: true),
        ),
      );
    }
  }

  Future<void> _onStartVerification(
    StartVerification event,
    Emitter<RegisterState> emit,
    VerifyEmailUseCase verifyEmailUseCase,
  ) async {
    emit(VerificationInProgress());

    const maxAttempts = 12;
    int attempts = 0;

    try {
      await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
        if (attempts >= maxAttempts) {
          emit(
            VerificationFailure(
              errorModel: ErrorModel(
                message: 'Verification timed out.',
                isError: true,
              ),
            ),
          );
          return;
        }
        attempts++;

        try {
          final result = await verifyEmailUseCase(event.email);

          result.fold(
            (error) => emit(
              VerificationFailure(
                errorModel: ErrorModel(
                  message: error.toString(),
                  isError: true,
                ),
              ),
            ),
            (isVerified) {
              if (isVerified) {
                emit(VerificationSuccess());
              }
            },
          );

          if (state is VerificationSuccess) {
            return;
          }
        } catch (error) {
          emit(
            VerificationFailure(
              errorModel: ErrorModel(message: error.toString(), isError: true),
            ),
          );
          return;
        }
      }
    } catch (error) {
      emit(
        VerificationFailure(
          errorModel: ErrorModel(message: error.toString(), isError: true),
        ),
      );
    }
  }
}