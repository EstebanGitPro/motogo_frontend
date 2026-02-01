part of 'edit_motorcycle_bloc.dart';

/// States for EditMotorcycleBloc.
abstract class EditMotorcycleState extends Equatable {
  const EditMotorcycleState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class EditMotorcycleInitial extends EditMotorcycleState {}

/// Saving state.
class EditMotorcycleSaving extends EditMotorcycleState {}

/// Success state with message.
class EditMotorcycleSuccess extends EditMotorcycleState {
  final String message;

  const EditMotorcycleSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state.
class EditMotorcycleError extends EditMotorcycleState {
  final String message;

  const EditMotorcycleError(this.message);

  @override
  List<Object?> get props => [message];
}
