part of 'my_motorcycles_bloc.dart';

/// States for MyMotorcyclesBloc.
abstract class MyMotorcyclesState extends Equatable {
  const MyMotorcyclesState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class MyMotorcyclesInitial extends MyMotorcyclesState {}

/// Loading state.
class MyMotorcyclesLoading extends MyMotorcyclesState {}

/// Loaded state with list of motorcycles.
class MyMotorcyclesLoaded extends MyMotorcyclesState {
  final List<MotorcycleEntity> motorcycles;

  const MyMotorcyclesLoaded(this.motorcycles);

  @override
  List<Object?> get props => [motorcycles];

  /// Whether the list is empty.
  bool get isEmpty => motorcycles.isEmpty;
}

/// Error state.
class MyMotorcyclesError extends MyMotorcyclesState {
  final String message;

  const MyMotorcyclesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when a motorcycle was successfully deleted.
class MyMotorcycleDeleted extends MyMotorcyclesState {
  final String message;

  const MyMotorcycleDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when motorcycle deletion failed.
class MyMotorcycleDeleteError extends MyMotorcyclesState {
  final String message;

  const MyMotorcycleDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
