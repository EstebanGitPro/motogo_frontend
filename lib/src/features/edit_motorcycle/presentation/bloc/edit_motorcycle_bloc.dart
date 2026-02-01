import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/domain/usecases/update_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

part 'edit_motorcycle_event.dart';
part 'edit_motorcycle_state.dart';

/// BLoC for editing an existing motorcycle.
class EditMotorcycleBloc
    extends Bloc<EditMotorcycleEvent, EditMotorcycleState> {
  final UpdateMotorcycleUseCase _updateMotorcycleUseCase;

  EditMotorcycleBloc({required UpdateMotorcycleUseCase updateMotorcycleUseCase})
    : _updateMotorcycleUseCase = updateMotorcycleUseCase,
      super(EditMotorcycleInitial()) {
    on<UpdateMotorcycle>(_onUpdateMotorcycle);
  }

  Future<void> _onUpdateMotorcycle(
    UpdateMotorcycle event,
    Emitter<EditMotorcycleState> emit,
  ) async {
    emit(EditMotorcycleSaving());

    final result = await _updateMotorcycleUseCase(event.id, event.motorcycle);

    result.fold(
      (error) => emit(EditMotorcycleError(error.message)),
      (message) => emit(EditMotorcycleSuccess(message)),
    );
  }
}
