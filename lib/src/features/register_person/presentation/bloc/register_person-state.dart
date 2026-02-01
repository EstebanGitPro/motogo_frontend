part of 'register_person_bloc.dart';

abstract class RegisterPersonState extends Equatable {
  const RegisterPersonState();

  @override
  List<Object> get props => [];
}

class RegisterPersonInitial extends RegisterPersonState {}

class RegisterPersonLoading extends RegisterPersonState {}

class RegisterPersonSuccess extends RegisterPersonState {
  final String email;
  final PersonEntity result;

  const RegisterPersonSuccess({required this.email, required this.result});

  @override
  List<Object> get props => [email, result];
}

class RegisterPersonFailure extends RegisterPersonState {
  final ErrorModel errorModel;

  const RegisterPersonFailure({required this.errorModel}) : super();

  @override
  List<Object> get props => [errorModel.message, errorModel.isError];
}

class VerificationPersonInProgress extends RegisterPersonState {}

class VerificationPersonSuccess extends RegisterPersonState {}

class VerificationPersonFailure extends RegisterPersonState {
  final ErrorModel errorModel;

  const VerificationPersonFailure({required this.errorModel});

  @override
  List<Object> get props => [errorModel.message, errorModel.isError];
}
