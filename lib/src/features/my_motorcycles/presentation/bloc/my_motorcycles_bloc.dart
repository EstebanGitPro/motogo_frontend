import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/usecases/delete_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/usecases/get_my_motorcycles_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

part 'my_motorcycles_event.dart';
part 'my_motorcycles_state.dart';

/// BLoC for managing the My Motorcycles list.
class MyMotorcyclesBloc extends Bloc<MyMotorcyclesEvent, MyMotorcyclesState> {
  final GetMyMotorcyclesUseCase _getMyMotorcyclesUseCase;
  final DeleteMotorcycleUseCase _deleteMotorcycleUseCase;

  MyMotorcyclesBloc({
    required GetMyMotorcyclesUseCase getMyMotorcyclesUseCase,
    required DeleteMotorcycleUseCase deleteMotorcycleUseCase,
  }) : _getMyMotorcyclesUseCase = getMyMotorcyclesUseCase,
       _deleteMotorcycleUseCase = deleteMotorcycleUseCase,
       super(MyMotorcyclesInitial()) {
    on<LoadMyMotorcycles>(_onLoadMyMotorcycles);
    on<DeleteMotorcycle>(_onDeleteMotorcycle);
  }

  Future<void> _onLoadMyMotorcycles(
    LoadMyMotorcycles event,
    Emitter<MyMotorcyclesState> emit,
  ) async {
    emit(MyMotorcyclesLoading());

    final result = await _getMyMotorcyclesUseCase();

    result.fold(
      (error) => emit(MyMotorcyclesError(error.message)),
      (motorcycles) => emit(MyMotorcyclesLoaded(motorcycles)),
    );
  }

  Future<void> _onDeleteMotorcycle(
    DeleteMotorcycle event,
    Emitter<MyMotorcyclesState> emit,
  ) async {
    emit(MyMotorcyclesLoading());

    final result = await _deleteMotorcycleUseCase(event.motorcycleId);

    await result.fold(
      (error) async => emit(MyMotorcycleDeleteError(error.message)),
      (message) async {
        emit(MyMotorcycleDeleted(message));
        // Reload the list after successful deletion
        add(const LoadMyMotorcycles());
      },
    );
  }
}
