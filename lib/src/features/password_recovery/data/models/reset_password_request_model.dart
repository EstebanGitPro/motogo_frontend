import 'dart:convert';

import 'package:motogo_frontend/src/features/password_recovery/domain/entities/password_reset_entity.dart';

class PasswordResetRequestModel extends PasswordResetEntity {
  PasswordResetRequestModel({
    required super.code,
    required super.newPassword,
  });

  

  factory PasswordResetRequestModel.fromJson(String str) => 
  PasswordResetRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PasswordResetRequestModel.fromMap(Map<String, dynamic> json) => PasswordResetRequestModel(
    code: json['code'] as String,
    newPassword: json['new_password'] as String,
  );

  Map<String, dynamic> toMap() => {
    'code': code,
    'new_password': newPassword,
  };
}
