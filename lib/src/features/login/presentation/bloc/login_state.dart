part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSuccess extends LoginState {
  final UserEntity user;
  final String message;
  final String code;

  const LoginSuccess({
    required this.user,
    required this.message,
    this.code = '',
  });

  @override
  List<Object> get props => [user, message, code];
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
