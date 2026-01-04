class PersonEntity {
  final String id;
  final String identityNumber;
  final String firstName;
  final String lastName;
  final String? secondLastName;
  final String email;
  final String phoneNumber;
  final bool emailVerified;
  final bool phoneNumberVerified;
  final String? password;
  final String role;

  PersonEntity({
    required this.id,
    required this.identityNumber,
    required this.firstName,
    required this.lastName,
    this.secondLastName,
    required this.email,
    required this.phoneNumber,
    required this.emailVerified,
    required this.phoneNumberVerified,
    this.password,
    required this.role,
  });
}
