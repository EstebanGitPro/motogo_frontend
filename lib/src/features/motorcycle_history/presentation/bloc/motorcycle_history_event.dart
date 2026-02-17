part of 'motorcycle_history_bloc.dart';

/// Events for the motorcycle history BLoC.
sealed class MotorcycleHistoryEvent extends Equatable {
  const MotorcycleHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the service history for a motorcycle.
class LoadMotorcycleHistory extends MotorcycleHistoryEvent {
  final String motorcycleId;

  const LoadMotorcycleHistory(this.motorcycleId);

  @override
  List<Object?> get props => [motorcycleId];
}
