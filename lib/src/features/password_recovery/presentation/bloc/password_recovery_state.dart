part of 'password_recovery_bloc.dart';

  sealed class PasswordResetState extends Equatable {
  const PasswordResetState();
  
  @override
  List<Object> get props => [];
}

final class PasswordResetInitial extends PasswordResetState {
  const PasswordResetInitial();
  
  @override
  List<Object> get props => [];
}

final class PasswordResetLoading extends PasswordResetState {
  const PasswordResetLoading();
  
  @override
  List<Object> get props => [];
}

final class PasswordResetSuccess extends PasswordResetState {
  const PasswordResetSuccess();
  
  @override
  List<Object> get props => [];
}

final class PasswordResetFailure extends PasswordResetState {
  final ErrorModel error;
  
  const PasswordResetFailure(this.error);
  
  @override
  List<Object> get props => [error];
}

