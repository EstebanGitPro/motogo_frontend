import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/user/data/models/user_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';

void main() {
  group('UserModel', () {
    // Sample data for tests
    const testId = 'user-001';
    const testIdentityNumber = '1234567890';
    const testFirstName = 'Juan';
    const testLastName = 'Pérez';
    const testSecondLastName = 'García';
    const testEmail = 'juan@example.com';
    const testPhoneNumber = '3001234567';
    const testRole = 'Representative';

    group('constructor', () {
      test('should create UserModel with all required fields', () {
        // Act
        const model = UserModel(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Assert
        expect(model.id, testId);
        expect(model.identityNumber, testIdentityNumber);
        expect(model.firstName, testFirstName);
        expect(model.lastName, testLastName);
        expect(model.secondLastName, isNull);
        expect(model.email, testEmail);
        expect(model.phoneNumber, testPhoneNumber);
        expect(model.role, testRole);
      });

      test('should create UserModel with optional secondLastName', () {
        // Act
        const model = UserModel(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          secondLastName: testSecondLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Assert
        expect(model.secondLastName, testSecondLastName);
      });
    });

    group('fromMap', () {
      test('should parse Map with all fields', () {
        // Arrange
        final map = {
          'id': testId,
          'identity_number': testIdentityNumber,
          'first_name': testFirstName,
          'last_name': testLastName,
          'second_last_name': testSecondLastName,
          'email': testEmail,
          'phone_number': testPhoneNumber,
          'role': testRole,
        };

        // Act
        final model = UserModel.fromMap(map);

        // Assert
        expect(model.id, testId);
        expect(model.identityNumber, testIdentityNumber);
        expect(model.firstName, testFirstName);
        expect(model.lastName, testLastName);
        expect(model.secondLastName, testSecondLastName);
        expect(model.email, testEmail);
        expect(model.phoneNumber, testPhoneNumber);
        expect(model.role, testRole);
      });

      test('should use empty string defaults for null values', () {
        // Arrange
        final map = <String, dynamic>{};

        // Act
        final model = UserModel.fromMap(map);

        // Assert
        expect(model.id, '');
        expect(model.identityNumber, '');
        expect(model.firstName, '');
        expect(model.lastName, '');
        expect(model.secondLastName, isNull);
        expect(model.email, '');
        expect(model.phoneNumber, '');
        expect(model.role, '');
      });

      test('should convert non-string types to string', () {
        // Arrange
        final map = {
          'id': 123,
          'identity_number': 1234567890,
          'first_name': testFirstName,
          'last_name': testLastName,
          'email': testEmail,
          'phone_number': 3001234567,
          'role': testRole,
        };

        // Act
        final model = UserModel.fromMap(map);

        // Assert
        expect(model.id, '123');
        expect(model.identityNumber, '1234567890');
        expect(model.phoneNumber, '3001234567');
      });
    });

    group('fromJson', () {
      test('should parse JSON string', () {
        // Arrange
        final jsonStr = json.encode({
          'id': testId,
          'identity_number': testIdentityNumber,
          'first_name': testFirstName,
          'last_name': testLastName,
          'email': testEmail,
          'phone_number': testPhoneNumber,
          'role': testRole,
        });

        // Act
        final model = UserModel.fromJson(jsonStr);

        // Assert
        expect(model.id, testId);
        expect(model.firstName, testFirstName);
      });
    });

    group('toMap', () {
      test('should serialize all fields to Map', () {
        // Arrange
        const model = UserModel(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          secondLastName: testSecondLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Act
        final map = model.toMap();

        // Assert
        expect(map['id'], testId);
        expect(map['identity_number'], testIdentityNumber);
        expect(map['first_name'], testFirstName);
        expect(map['last_name'], testLastName);
        expect(map['second_last_name'], testSecondLastName);
        expect(map['email'], testEmail);
        expect(map['phone_number'], testPhoneNumber);
        expect(map['role'], testRole);
      });
    });

    group('toJson', () {
      test('should serialize to JSON string', () {
        // Arrange
        const model = UserModel(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Act
        final jsonStr = model.toJson();
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;

        // Assert
        expect(decoded['id'], testId);
        expect(decoded['first_name'], testFirstName);
      });
    });

    group('toUpdateMap', () {
      test('should only include editable fields', () {
        // Arrange
        const model = UserModel(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          secondLastName: testSecondLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Act
        final map = model.toUpdateMap();

        // Assert
        expect(map.containsKey('first_name'), isTrue);
        expect(map.containsKey('last_name'), isTrue);
        expect(map.containsKey('second_last_name'), isTrue);
        expect(map.containsKey('phone_number'), isTrue);
        // Non-editable fields should NOT be present
        expect(map.containsKey('id'), isFalse);
        expect(map.containsKey('identity_number'), isFalse);
        expect(map.containsKey('email'), isFalse);
        expect(map.containsKey('role'), isFalse);
      });
    });

    group('fromEntity', () {
      test('should create UserModel from UserEntity', () {
        // Arrange
        const entity = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          secondLastName: testSecondLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Act
        final model = UserModel.fromEntity(entity);

        // Assert
        expect(model.id, entity.id);
        expect(model.firstName, entity.firstName);
        expect(model.secondLastName, entity.secondLastName);
      });
    });

    group('copyWith', () {
      test('should copy with updated fields', () {
        // Arrange
        const original = UserModel(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Act
        final copied = original.copyWith(
          firstName: 'Carlos',
          phoneNumber: '3009999999',
        );

        // Assert
        expect(copied.id, testId); // unchanged
        expect(copied.firstName, 'Carlos'); // changed
        expect(copied.lastName, testLastName); // unchanged
        expect(copied.phoneNumber, '3009999999'); // changed
      });

      test('should return same values when no arguments provided', () {
        // Arrange
        const original = UserModel(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied.id, original.id);
        expect(copied.firstName, original.firstName);
        expect(copied.email, original.email);
      });
    });
  });
}
