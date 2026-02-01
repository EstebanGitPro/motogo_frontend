import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

/// States for the RegisterMotorcycle BLoC.
sealed class RegisterMotorcycleState extends Equatable {
  const RegisterMotorcycleState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any action.
class RegisterMotorcycleInitial extends RegisterMotorcycleState {
  const RegisterMotorcycleInitial();
}

/// State while registration is in progress.
class RegisterMotorcycleLoading extends RegisterMotorcycleState {
  const RegisterMotorcycleLoading();
}

/// State when registration completes successfully.
class RegisterMotorcycleSuccess extends RegisterMotorcycleState {
  final String message;

  const RegisterMotorcycleSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when registration fails.
class RegisterMotorcycleFailure extends RegisterMotorcycleState {
  final ErrorModel error;

  const RegisterMotorcycleFailure(this.error);

  @override
  List<Object?> get props => [error];
}
