import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

/// Base class for all register franchise states.
abstract class RegisterFranchiseState extends Equatable {
  const RegisterFranchiseState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the form is ready.
class RegisterFranchiseInitial extends RegisterFranchiseState {
  const RegisterFranchiseInitial();
}

/// State when the franchise is being registered.
class RegisterFranchiseLoading extends RegisterFranchiseState {
  const RegisterFranchiseLoading();
}

/// State when the franchise was successfully registered.
class RegisterFranchiseSuccess extends RegisterFranchiseState {
  final FranchiseEntity franchise;
  final String message;

  const RegisterFranchiseSuccess({
    required this.franchise,
    required this.message,
  });

  @override
  List<Object?> get props => [franchise, message];
}

/// State when the franchise registration failed.
class RegisterFranchiseError extends RegisterFranchiseState {
  final String code;
  final String message;

  const RegisterFranchiseError({required this.code, required this.message});

  @override
  List<Object?> get props => [code, message];
}
