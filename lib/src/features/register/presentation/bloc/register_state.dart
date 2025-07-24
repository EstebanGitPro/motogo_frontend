part of 'register_bloc.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String email;
  final PersonEntity result;

  const RegisterSuccess({
    required this.email,
    required this.result,
  });

  @override
  List<Object> get props => [email, result];
}

class RegisterFailure extends RegisterState {
  final ErrorModel errorModel;

  const RegisterFailure({required this.errorModel}) : super();

  @override
  List<Object> get props => [errorModel.message, errorModel.isError];
}

class VerificationInProgress extends RegisterState {}

class VerificationSuccess extends RegisterState {}

class VerificationFailure extends RegisterState {
  final ErrorModel errorModel;

  const VerificationFailure({required this.errorModel});

  @override
  List<Object> get props => [errorModel.message, errorModel.isError];
}