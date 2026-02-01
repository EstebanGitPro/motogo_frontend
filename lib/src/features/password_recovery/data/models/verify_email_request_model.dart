import 'dart:convert';

import 'package:motogo_frontend/src/features/password_recovery/domain/entities/verify_email_entity.dart';

class VerifyEmailRequestModel extends VerifyEmailEntity {
  VerifyEmailRequestModel({required super.email});

  factory VerifyEmailRequestModel.fromJson(String str) =>
      VerifyEmailRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VerifyEmailRequestModel.fromMap(Map<String, dynamic> json) =>
      VerifyEmailRequestModel(email: json['email']);

  Map<String, dynamic> toMap() => {'email': email};
}
