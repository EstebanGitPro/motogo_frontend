import 'dart:convert';

import 'package:motogo_frontend/src/features/password_recovery/domain/entities/validate_code_entity.dart';

class ValidateCodeRequestModel extends VerifyCodeEntity {
  ValidateCodeRequestModel({required super.code});

  factory ValidateCodeRequestModel.fromJson(String str) =>
      ValidateCodeRequestModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ValidateCodeRequestModel.fromMap(Map<String, dynamic> json) =>
      ValidateCodeRequestModel(code: json["code"]);

  Map<String, dynamic> toMap() => {"code": code};
}
