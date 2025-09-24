part of 'register_person_bloc.dart';

abstract class RegisterPersonEvent extends Equatable {
  const RegisterPersonEvent();

  @override
  List<Object> get props => [];
}

class StartVerification extends RegisterPersonEvent {
  final String email;

  const StartVerification(this.email);

  @override
  List<Object> get props => [email];
}

class RegisterPersonSubmitted extends RegisterPersonEvent {
  final String identityNumber;
  final String firstName;
  final String lastName;
  final String? secondLastName;
  final String email;
  final String phoneNumber;
  final bool emailVerified;
  final bool phoneNumberVerified;
  final String password;
  final String role;

  const RegisterPersonSubmitted({
    required this.identityNumber,
    required this.firstName,
    required this.lastName,
    this.secondLastName,
    required this.email,
    required this.phoneNumber,
    required this.emailVerified,
    required this.phoneNumberVerified,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [
    identityNumber,
    firstName,
    lastName,
    secondLastName ?? '',
    email,
    phoneNumber,
    emailVerified,
    phoneNumberVerified,
    password,
    role,
  ];
}
