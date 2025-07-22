part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final PersonEntity person;

  const LoginSuccess(this.person);

  @override
  List<Object> get props => [person];
}

class LoginFailure extends LoginState {
  final ErrorModel error;

  const LoginFailure(this.error);

  @override
  List<Object> get props => [error];
}

class LoginNeedsVerification extends LoginState {
  final String? message;

  const LoginNeedsVerification({this.message});

  @override
  List<Object> get props => [message ?? ''];
}