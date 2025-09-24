import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/verify_email/domain/usecases/verify_email_usecase.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/core/errors/error_message_mapper.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';


part 'register_person_event.dart';
part 'register_person-state.dart';

class RegisterPersonBloc extends Bloc<RegisterPersonEvent, RegisterPersonState> {
  RegisterPersonBloc() : super(RegisterPersonInitial()) {
    final registerUseCase = InjectorApp.resolve<RegisterPersonUseCase>();
    final verifyEmailUseCase = InjectorApp.resolve<VerifyEmailUseCase>();

    on<RegisterPersonSubmitted>(
      (event, emit) => _onRegisterSubmitted(event, emit, registerUseCase),
    );

    on<StartVerification>(
      (event, emit) => _onStartVerification(event, emit, verifyEmailUseCase),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterPersonSubmitted event,
    Emitter<RegisterPersonState> emit,
    RegisterPersonUseCase registerUseCase,
  ) async {
    emit(RegisterPersonLoading());
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
          RegisterPersonFailure(
            errorModel: ErrorModel(
              message: ErrorMessageMapper.mapServerError(error.message),
            ),
          ),
        ),
      
        (person) => emit(RegisterPersonSuccess(
          result: person, 
          email: event.email, 
        )),
      );
    } catch (error) {
      emit(
        RegisterPersonFailure(
          errorModel: ErrorModel(message: error.toString(), isError: true),
        ),
      );
    }
  }

  Future<void> _onStartVerification(
    StartVerification event,
    Emitter<RegisterPersonState> emit,
    VerifyEmailUseCase verifyEmailUseCase,
  ) async {
    emit(VerificationPersonInProgress());

    const maxAttempts = 12;
    int attempts = 0;

    try {
      await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
        if (attempts >= maxAttempts) {
          emit(
            VerificationPersonFailure(
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
              VerificationPersonFailure(
                errorModel: ErrorModel(
                  message: error.toString(),
                  isError: true,
                ),
              ),
            ),
            (isVerified) {
              if (isVerified) {
                emit(VerificationPersonSuccess());
              }
            },
          );

          if (state is VerificationPersonSuccess) {
            return;
          }
        } catch (error) {
          emit(
            VerificationPersonFailure(
              errorModel: ErrorModel(message: error.toString(), isError: true),
            ),
          );
          return;
        }
      }
    } catch (error) {
      emit(
        VerificationPersonFailure(
          errorModel: ErrorModel(message: error.toString(), isError: true),
        ),
      );
    }
  }
}