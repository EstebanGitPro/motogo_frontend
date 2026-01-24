import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/password_recovery/data/models/verify_email_request_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/entities/verify_email_entity.dart';

void main() {
  group('VerifyEmailRequestModel', () {
    const testEmail = 'user@example.com';
    final testMap = {'email': testEmail};

    group('fromMap', () {
      test('should create model from map', () {
        final model = VerifyEmailRequestModel.fromMap(testMap);

        expect(model.email, testEmail);
      });
    });

    group('fromJson', () {
      test('should create model from JSON string', () {
        final jsonString = json.encode(testMap);

        final model = VerifyEmailRequestModel.fromJson(jsonString);

        expect(model.email, testEmail);
      });
    });

    group('toMap', () {
      test('should serialize model to map', () {
        final model = VerifyEmailRequestModel(email: 'test@test.com');

        final map = model.toMap();

        expect(map['email'], 'test@test.com');
      });
    });

    group('toJson', () {
      test('should serialize model to JSON string', () {
        final model = VerifyEmailRequestModel(email: 'json@test.com');

        final jsonString = model.toJson();
        final decoded = json.decode(jsonString);

        expect(decoded['email'], 'json@test.com');
      });
    });

    group('inheritance', () {
      test('should extend VerifyEmailEntity', () {
        final model = VerifyEmailRequestModel(email: 'test@email.com');

        expect(model, isA<VerifyEmailEntity>());
      });
    });
  });
}
