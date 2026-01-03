import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';

part 'register_person_event.dart';
part 'register_person-state.dart';

class RegisterPersonBloc
    extends Bloc<RegisterPersonEvent, RegisterPersonState> {
  RegisterPersonBloc() : super(RegisterPersonInitial()) {
    final registerUseCase = InjectorApp.resolve<RegisterPersonUseCase>();

    on<RegisterPersonSubmitted>(
      (event, emit) => _onRegisterSubmitted(event, emit, registerUseCase),
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
        (error) => emit(RegisterPersonFailure(errorModel: error)),
        (person) =>
            emit(RegisterPersonSuccess(result: person, email: event.email)),
      );
    } catch (error) {
      emit(
        RegisterPersonFailure(
          errorModel: ErrorModel(
            message: 'Error inesperado',
            description: error.toString(),
            statusCode: 500,
            errorCode: 'CLIENT_ERROR',
          ),
        ),
      );
    }
  }
}
