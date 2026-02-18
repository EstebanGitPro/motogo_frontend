import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';
import 'package:motogo_frontend/src/features/register_person/domain/usecases/register_person_usecase.dart';

part 'register_person_event.dart';
part 'register_person-state.dart';

class RegisterPersonBloc
    extends Bloc<RegisterPersonEvent, RegisterPersonState> {
  final RegisterPersonUseCase _registerUseCase;

  RegisterPersonBloc({required RegisterPersonUseCase registerUseCase})
    : _registerUseCase = registerUseCase,
      super(RegisterPersonInitial()) {
    on<RegisterPersonSubmitted>(
      (event, emit) => _onRegisterSubmitted(event, emit, _registerUseCase),
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterPersonSubmitted event,
    Emitter<RegisterPersonState> emit,
    RegisterPersonUseCase registerUseCase,
  ) async {
    emit(RegisterPersonLoading());
    try {
      final params = RegisterPersonParams(
        identityNumber: event.identityNumber,
        firstName: event.firstName,
        lastName: event.lastName,
        secondLastName: event.secondLastName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
        role: event.role,
      );
      final result = await registerUseCase(params);

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
