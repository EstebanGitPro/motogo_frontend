part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final PersonEntity user;

  const LoginSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class LoginFailure extends LoginState {
  final ErrorModel error;

  const LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class LoginNeedsVerification extends LoginState {
  final String? message;

  const LoginNeedsVerification({this.message});

  @override
  List<Object> get props => [message ?? ''];
}

class LoginLoggedOut extends LoginState {}
