// ignore_for_file: public_member_api_docs, sort_constructors_first
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

  PersonEntity copyWith({
    String? identityNumber,
    String? firstName,
    String? lastName,
    String? secondLastName,
    String? phoneNumber,
    String? password,
  }) {
    return PersonEntity(
      id: id,
      identityNumber: identityNumber ?? this.identityNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified,
      phoneNumberVerified: phoneNumberVerified,
      password: password ?? this.password,
      role: role,
    );
  }
}
