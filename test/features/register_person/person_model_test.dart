import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_person/data/models/person_model.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_entity.dart';

void main() {
  group('PersonModel', () {
    final testMap = {
      'id': 'person-abc123',
      'identity_number': '1234567890',
      'first_name': 'Juan',
      'last_name': 'García',
      'second_last_name': 'López',
      'email': 'juan.garcia@example.com',
      'phone_number': '+573001234567',
      'email_verified': true,
      'phone_number_verified': false,
      'password': 'securePass123',
      'role': 'representative',
    };

    group('fromMap', () {
      test('should create model from complete map', () {
        final model = PersonModel.fromMap(testMap);

        expect(model.id, 'person-abc123');
        expect(model.identityNumber, '1234567890');
        expect(model.firstName, 'Juan');
        expect(model.lastName, 'García');
        expect(model.secondLastName, 'López');
        expect(model.email, 'juan.garcia@example.com');
        expect(model.phoneNumber, '+573001234567');
        expect(model.emailVerified, true);
        expect(model.phoneNumberVerified, false);
        expect(model.role, 'representative');
      });

      test('should handle null second_last_name', () {
        final mapWithoutSecondLastName = {...testMap, 'second_last_name': null};

        final model = PersonModel.fromMap(mapWithoutSecondLastName);

        expect(model.secondLastName, null);
      });
    });

    group('fromJson', () {
      test('should create model from JSON string', () {
        final jsonString = json.encode(testMap);

        final model = PersonModel.fromJson(jsonString);

        expect(model.id, 'person-abc123');
        expect(model.firstName, 'Juan');
        expect(model.lastName, 'García');
        expect(model.email, 'juan.garcia@example.com');
      });
    });

    group('toMap', () {
      test('should serialize model to map', () {
        final model = PersonModel(
          id: 'user-xyz',
          identityNumber: '9876543210',
          firstName: 'María',
          lastName: 'Rodríguez',
          secondLastName: 'Pérez',
          email: 'maria@test.com',
          phoneNumber: '+573009876543',
          emailVerified: true,
          phoneNumberVerified: true,
          role: 'admin',
        );

        final map = model.toMap();

        expect(map['id'], 'user-xyz');
        expect(map['identity_number'], '9876543210');
        expect(map['first_name'], 'María');
        expect(map['last_name'], 'Rodríguez');
        expect(map['second_last_name'], 'Pérez');
        expect(map['email'], 'maria@test.com');
        expect(map['phone_number'], '+573009876543');
        expect(map['email_verified'], true);
        expect(map['phone_number_verified'], true);
        expect(map['role'], 'admin');
      });

      test('should set password to empty string when null', () {
        final model = PersonModel(
          id: 'test',
          identityNumber: '123',
          firstName: 'Test',
          lastName: 'User',
          email: 'test@test.com',
          phoneNumber: '+57300',
          emailVerified: false,
          phoneNumberVerified: false,
          role: 'user',
        );

        final map = model.toMap();

        expect(map['password'], '');
      });
    });

    group('toJson', () {
      test('should serialize model to JSON string', () {
        final model = PersonModel(
          id: 'json-test',
          identityNumber: '111222333',
          firstName: 'Carlos',
          lastName: 'Martínez',
          email: 'carlos@example.com',
          phoneNumber: '+573001112233',
          emailVerified: false,
          phoneNumberVerified: false,
          role: 'client',
        );

        final jsonString = model.toJson();
        final decoded = json.decode(jsonString);

        expect(decoded['id'], 'json-test');
        expect(decoded['first_name'], 'Carlos');
        expect(decoded['email'], 'carlos@example.com');
      });
    });

    group('inheritance', () {
      test('should extend PersonEntity', () {
        final model = PersonModel(
          id: 'id',
          identityNumber: '123',
          firstName: 'F',
          lastName: 'L',
          email: 'e@e.com',
          phoneNumber: '123',
          emailVerified: false,
          phoneNumberVerified: false,
          role: 'test',
        );

        expect(model, isA<PersonEntity>());
      });
    });
  });
}
