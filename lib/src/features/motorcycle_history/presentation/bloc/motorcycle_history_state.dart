part of 'motorcycle_history_bloc.dart';

/// States for the motorcycle history BLoC.
sealed class MotorcycleHistoryState extends Equatable {
  const MotorcycleHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class MotorcycleHistoryInitial extends MotorcycleHistoryState {}

/// Loading state while fetching service history.
class MotorcycleHistoryLoading extends MotorcycleHistoryState {}

/// Loaded state with the list of completed services.
class MotorcycleHistoryLoaded extends MotorcycleHistoryState {
  final List<CompletedServiceEntity> services;

  const MotorcycleHistoryLoaded(this.services);

  bool get isEmpty => services.isEmpty;

  @override
  List<Object?> get props => [services];
}

/// Error state when fetching fails.
class MotorcycleHistoryError extends MotorcycleHistoryState {
  final String message;

  const MotorcycleHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
