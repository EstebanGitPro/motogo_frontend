/// Encapsulates registration parameters to reduce function parameter count.
class RegisterPersonParams {
  final String identityNumber;
  final String firstName;
  final String lastName;
  final String? secondLastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String role;

  const RegisterPersonParams({
    required this.identityNumber,
    required this.firstName,
    required this.lastName,
    this.secondLastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.role,
  });
}
