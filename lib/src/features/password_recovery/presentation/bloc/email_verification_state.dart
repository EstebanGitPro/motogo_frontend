part of 'email_verification_bloc.dart';

abstract class EmailRecoveryVerificationState extends Equatable {
  const EmailRecoveryVerificationState();
}

class EmailRecoveryVerificationInitial extends EmailRecoveryVerificationState {
  const EmailRecoveryVerificationInitial();

  @override
  List<Object> get props => [];
}

class EmailRecoveryVerificationLoading extends EmailRecoveryVerificationState {
  const EmailRecoveryVerificationLoading();

  @override
  List<Object> get props => [];
}

class EmailRecoveryVerificationSuccess extends EmailRecoveryVerificationState {
  const EmailRecoveryVerificationSuccess();

  @override
  List<Object> get props => [];
}

class EmailRecoveryVerificationFailure extends EmailRecoveryVerificationState {
  final ErrorModel error;

  const EmailRecoveryVerificationFailure(this.error);

  @override
  List<Object> get props => [error];
}
