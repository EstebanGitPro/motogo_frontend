import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/entities/verify_email_entity.dart';

void main() {
  group('VerifyEmailEntity', () {
    group('constructor', () {
      test('should create instance with required email', () {
        // Act
        final entity = VerifyEmailEntity(email: 'test@example.com');

        // Assert
        expect(entity.email, 'test@example.com');
      });

      test('should store email correctly', () {
        // Act
        final entity = VerifyEmailEntity(email: 'user@domain.co');

        // Assert
        expect(entity.email, 'user@domain.co');
      });

      test('should handle special characters in email', () {
        // Act
        final entity = VerifyEmailEntity(email: 'user+tag@sub.domain.com');

        // Assert
        expect(entity.email, 'user+tag@sub.domain.com');
      });

      test('should handle empty email', () {
        // Act
        final entity = VerifyEmailEntity(email: '');

        // Assert
        expect(entity.email, isEmpty);
      });
    });
  });
}
