import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/usecases/register_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_event.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_state.dart';

/// BLoC for motorcycle registration.
///
/// Handles the registration flow: validates input, calls the use case,
/// and emits appropriate states.
class RegisterMotorcycleBloc
    extends Bloc<RegisterMotorcycleEvent, RegisterMotorcycleState> {
  final RegisterMotorcycleUseCase _registerMotorcycleUseCase;

  RegisterMotorcycleBloc(this._registerMotorcycleUseCase)
    : super(const RegisterMotorcycleInitial()) {
    on<SubmitMotorcycleRegistration>(_onSubmitRegistration);
    on<ResetMotorcycleForm>(_onResetForm);
  }

  Future<void> _onSubmitRegistration(
    SubmitMotorcycleRegistration event,
    Emitter<RegisterMotorcycleState> emit,
  ) async {
    emit(const RegisterMotorcycleLoading());

    final result = await _registerMotorcycleUseCase(
      licensePlate: event.licensePlate,
      year: event.year,
      currentMileage: event.currentMileage,
      ownerNotes: event.ownerNotes,
    );

    result.fold(
      (error) => emit(RegisterMotorcycleFailure(error)),
      (message) => emit(RegisterMotorcycleSuccess(message)),
    );
  }

  void _onResetForm(
    ResetMotorcycleForm event,
    Emitter<RegisterMotorcycleState> emit,
  ) {
    emit(const RegisterMotorcycleInitial());
  }
}
