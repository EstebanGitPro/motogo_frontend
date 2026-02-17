import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/domain/usecases/get_motorcycle_history_usecase.dart';

part 'motorcycle_history_event.dart';
part 'motorcycle_history_state.dart';

/// BLoC for managing the motorcycle service history page.
class MotorcycleHistoryBloc
    extends Bloc<MotorcycleHistoryEvent, MotorcycleHistoryState> {
  final GetMotorcycleHistoryUseCase _getMotorcycleHistoryUseCase;

  MotorcycleHistoryBloc({
    required GetMotorcycleHistoryUseCase getMotorcycleHistoryUseCase,
  }) : _getMotorcycleHistoryUseCase = getMotorcycleHistoryUseCase,
       super(MotorcycleHistoryInitial()) {
    on<LoadMotorcycleHistory>(_onLoadMotorcycleHistory);
  }

  Future<void> _onLoadMotorcycleHistory(
    LoadMotorcycleHistory event,
    Emitter<MotorcycleHistoryState> emit,
  ) async {
    emit(MotorcycleHistoryLoading());

    final result = await _getMotorcycleHistoryUseCase(event.motorcycleId);

    result.fold(
      (error) => emit(MotorcycleHistoryError(error.message)),
      (services) => emit(MotorcycleHistoryLoaded(services)),
    );
  }
}
