import 'package:equatable/equatable.dart';

/// Entidad unificada que representa al usuario autenticado.
/// Usada en toda la aplicación para manejar los datos del usuario.
class UserEntity extends Equatable {
  final String id;
  final String identityNumber;
  final String firstName;
  final String lastName;
  final String? secondLastName;
  final String email;
  final String phoneNumber;
  final String role;

  const UserEntity({
    // NOSONAR - 8 parámetros atómicos del dominio, agruparlos artificialmente no se justifica
    required this.id,
    required this.identityNumber,
    required this.firstName,
    required this.lastName,
    this.secondLastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  /// Nombre completo del usuario
  String get fullName {
    final parts = [firstName, lastName];
    if (secondLastName != null && secondLastName!.isNotEmpty) {
      parts.add(secondLastName!);
    }
    return parts.join(' ');
  }

  /// Crea una copia de la entidad con los valores especificados
  UserEntity copyWith({
    // NOSONAR - copyWith refleja los mismos 8 campos del constructor
    String? id,
    String? identityNumber,
    String? firstName,
    String? lastName,
    String? secondLastName,
    String? email,
    String? phoneNumber,
    String? role,
  }) {
    return UserEntity(
      id: id ?? this.id,
      identityNumber: identityNumber ?? this.identityNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [
    id,
    identityNumber,
    firstName,
    lastName,
    secondLastName,
    email,
    phoneNumber,
    role,
  ];
}
