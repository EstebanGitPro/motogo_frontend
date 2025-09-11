part of 'password_recovery_bloc.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object> get props => [];
}

class ResetPasswordSubmitted extends PasswordResetEvent {
  final String code;
  final String newPassword;

  const ResetPasswordSubmitted({required this.code, required this.newPassword});

  @override
  List<Object> get props => [code, newPassword];
}
