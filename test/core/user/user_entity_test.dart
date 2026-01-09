import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    const testId = 'user-001';
    const testIdentityNumber = '1234567890';
    const testFirstName = 'Juan';
    const testLastName = 'Pérez';
    const testSecondLastName = 'García';
    const testEmail = 'juan@example.com';
    const testPhoneNumber = '3001234567';
    const testRole = 'Representative';

    group('constructor', () {
      test('should create entity with required fields', () {
        const entity = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        expect(entity.id, testId);
        expect(entity.firstName, testFirstName);
        expect(entity.secondLastName, isNull);
      });

      test('should create entity with optional secondLastName', () {
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

        expect(entity.secondLastName, testSecondLastName);
      });
    });

    group('fullName', () {
      test('should return firstName and lastName', () {
        const entity = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        expect(entity.fullName, 'Juan Pérez');
      });

      test('should include secondLastName when present', () {
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

        expect(entity.fullName, 'Juan Pérez García');
      });

      test('should not include empty secondLastName', () {
        const entity = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          secondLastName: '',
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        expect(entity.fullName, 'Juan Pérez');
      });
    });

    group('copyWith', () {
      test('should copy with updated fields', () {
        const original = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        final copied = original.copyWith(firstName: 'Carlos');

        expect(copied.firstName, 'Carlos');
        expect(copied.lastName, testLastName);
        expect(copied.id, testId);
      });

      test('should return same values when no arguments', () {
        const original = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.firstName, original.firstName);
      });
    });

    group('props', () {
      test('should include all fields in props', () {
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

        expect(entity.props.length, 8);
        expect(entity.props.contains(testId), isTrue);
        expect(entity.props.contains(testFirstName), isTrue);
      });
    });

    group('equality', () {
      test('should be equal when all fields are same', () {
        const entity1 = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        const entity2 = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        expect(entity1, equals(entity2));
      });

      test('should not be equal when fields differ', () {
        const entity1 = UserEntity(
          id: testId,
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        const entity2 = UserEntity(
          id: 'different-id',
          identityNumber: testIdentityNumber,
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          role: testRole,
        );

        expect(entity1, isNot(equals(entity2)));
      });
    });
  });
}
