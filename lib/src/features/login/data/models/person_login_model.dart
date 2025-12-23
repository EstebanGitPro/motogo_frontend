import 'dart:convert';
import 'package:motogo_frontend/src/features/login/domain/entities/person_login_entity.dart';

class PersonModel extends PersonEntity {
  PersonModel({
    required super.id,
    required super.identityNumber,
    required super.firstName,
    required super.lastName,
    super.secondLastName,
    required super.email,
    required super.phoneNumber,
    String? password,
    required super.role,
    required super.token,
  });

  factory PersonModel.fromJson(String str) =>
      PersonModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PersonModel.fromMap(Map<String, dynamic> json) => PersonModel(
    id: json["id"],
    identityNumber: json["identity_number"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    secondLastName: json["second_last_name"],
    email: json["email"],
    phoneNumber: json["phone_number"],
    password: json["password"],
    role: json["role"],
    token: json["token"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "identity_number": identityNumber,
    "first_name": firstName,
    "last_name": lastName,
    "second_last_name": secondLastName,
    "email": email,
    "phone_number": phoneNumber,
    "password": password ?? '',
    "role": role,
    "token": token
  };
}
