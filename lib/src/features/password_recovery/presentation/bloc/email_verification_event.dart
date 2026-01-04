part of 'email_verification_bloc.dart';

abstract class EmailRecoveryVerificationEvent extends Equatable {
  const EmailRecoveryVerificationEvent();
}

class EmailRecoveryVerificationSubmitted extends EmailRecoveryVerificationEvent {
  final String email;

  const EmailRecoveryVerificationSubmitted({required this.email});

  @override
  List<Object> get props => [email];
}
