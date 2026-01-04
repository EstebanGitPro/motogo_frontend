import 'dart:convert';

import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';

/// Modelo de datos para el usuario, con serialización JSON.
/// Extiende UserEntity y añade métodos de conversión.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.identityNumber,
    required super.firstName,
    required super.lastName,
    super.secondLastName,
    required super.email,
    required super.phoneNumber,
    required super.role,
  });

  /// Crea un UserModel desde un JSON string
  factory UserModel.fromJson(String str) =>
      UserModel.fromMap(json.decode(str) as Map<String, dynamic>);

  /// Convierte a JSON string
  String toJson() => json.encode(toMap());

  /// Crea un UserModel desde un Map (respuesta del API)
  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    identityNumber: json['identity_number']?.toString() ?? '',
    firstName: json['first_name']?.toString() ?? '',
    lastName: json['last_name']?.toString() ?? '',
    secondLastName: json['second_last_name']?.toString(),
    email: json['email']?.toString() ?? '',
    phoneNumber: json['phone_number']?.toString() ?? '',
    role: json['role']?.toString() ?? '',
  );

  /// Crea un UserModel desde una UserEntity
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    identityNumber: entity.identityNumber,
    firstName: entity.firstName,
    lastName: entity.lastName,
    secondLastName: entity.secondLastName,
    email: entity.email,
    phoneNumber: entity.phoneNumber,
    role: entity.role,
  );

  /// Convierte a Map para enviar al API o guardar en storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'identity_number': identityNumber,
    'first_name': firstName,
    'last_name': lastName,
    'second_last_name': secondLastName,
    'email': email,
    'phone_number': phoneNumber,
    'role': role,
  };

  /// Convierte a Map solo con los campos editables (para update)
  Map<String, dynamic> toUpdateMap() => {
    'first_name': firstName,
    'last_name': lastName,
    'second_last_name': secondLastName,
    'phone_number': phoneNumber,
  };

  @override
  UserModel copyWith({
    String? id,
    String? identityNumber,
    String? firstName,
    String? lastName,
    String? secondLastName,
    String? email,
    String? phoneNumber,
    String? role,
  }) {
    return UserModel(
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
}
