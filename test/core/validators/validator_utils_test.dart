import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/validators/base_validator.dart';
import 'package:motogo_frontend/src/core/validators/validator_utils.dart';

void main() {
  group('ValidatorUtils', () {
    group('email', () {
      test('should create EmailValidator', () {
        final validator = ValidatorUtils.email();
        expect(validator, isA<BaseValidator>());
      });

      test('should validate valid email', () {
        final validator = ValidatorUtils.email();
        expect(validator.validate('test@example.com'), isNull);
      });

      test('should reject invalid email', () {
        final validator = ValidatorUtils.email();
        expect(validator.validate('invalid-email'), isNotNull);
      });

      test('should use custom message', () {
        final validator = ValidatorUtils.email(customMessage: 'Custom error');
        final result = validator.validate('invalid');
        expect(result, 'Custom error');
      });
    });

    group('password', () {
      test('should create PasswordValidator with defaults', () {
        final validator = ValidatorUtils.password();
        expect(validator, isA<BaseValidator>());
      });

      test('should validate strong password', () {
        final validator = ValidatorUtils.password();
        expect(validator.validate('Password1'), isNull);
      });

      test('should reject weak password', () {
        final validator = ValidatorUtils.password();
        expect(validator.validate('weak'), isNotNull);
      });

      test('should respect custom minLength', () {
        final validator = ValidatorUtils.password(minLength: 4);
        expect(validator.validate('Pass1'), isNull);
      });
    });

    group('confirmPassword', () {
      test('should validate matching passwords', () {
        final validator = ValidatorUtils.confirmPassword('Password1');
        expect(validator.validate('Password1'), isNull);
      });

      test('should reject non-matching passwords', () {
        final validator = ValidatorUtils.confirmPassword('Password1');
        expect(validator.validate('Password2'), isNotNull);
      });

      test('should use custom message', () {
        final validator = ValidatorUtils.confirmPassword(
          'Password1',
          customMessage: 'No coinciden',
        );
        final result = validator.validate('Different');
        expect(result, 'No coinciden');
      });
    });

    group('name', () {
      test('should validate valid name', () {
        final validator = ValidatorUtils.name();
        expect(validator.validate('Juan'), isNull);
      });

      test('should reject too short name', () {
        final validator = ValidatorUtils.name(minLength: 3);
        expect(validator.validate('Jo'), isNotNull);
      });

      test('should reject too long name', () {
        final validator = ValidatorUtils.name(maxLength: 5);
        expect(validator.validate('JuanCarlos'), isNotNull);
      });
    });

    group('identity', () {
      test('should validate valid identity', () {
        final validator = ValidatorUtils.identity();
        expect(validator.validate('12345678'), isNull);
      });

      test('should reject too short identity', () {
        final validator = ValidatorUtils.identity(minLength: 8);
        expect(validator.validate('1234'), isNotNull);
      });

      test('should reject too long identity', () {
        final validator = ValidatorUtils.identity(maxLength: 10);
        expect(validator.validate('12345678901234'), isNotNull);
      });
    });

    group('phone', () {
      test('should validate valid phone', () {
        final validator = ValidatorUtils.phone();
        expect(validator.validate('3001234567'), isNull);
      });

      test('should reject invalid phone', () {
        final validator = ValidatorUtils.phone();
        expect(validator.validate('invalid'), isNotNull);
      });
    });

    group('required', () {
      test('should validate non-empty value', () {
        final validator = ValidatorUtils.required();
        expect(validator.validate('value'), isNull);
      });

      test('should reject empty value', () {
        final validator = ValidatorUtils.required();
        expect(validator.validate(''), isNotNull);
      });

      test('should reject null value', () {
        final validator = ValidatorUtils.required();
        expect(validator.validate(null), isNotNull);
      });
    });

    group('minLength', () {
      test('should validate when meets minimum', () {
        final validator = ValidatorUtils.minLength(5);
        expect(validator.validate('hello'), isNull);
      });

      test('should reject when below minimum', () {
        final validator = ValidatorUtils.minLength(5);
        expect(validator.validate('hi'), isNotNull);
      });
    });

    group('maxLength', () {
      test('should validate when within maximum', () {
        final validator = ValidatorUtils.maxLength(5);
        expect(validator.validate('hi'), isNull);
      });

      test('should reject when exceeds maximum', () {
        final validator = ValidatorUtils.maxLength(5);
        expect(validator.validate('hello world'), isNotNull);
      });
    });

    group('compose', () {
      test('should combine multiple validators', () {
        final validator = ValidatorUtils.compose([
          ValidatorUtils.required(),
          ValidatorUtils.minLength(3),
        ]);

        expect(validator.validate('hello'), isNull);
        expect(validator.validate(''), isNotNull);
        expect(validator.validate('ab'), isNotNull);
      });
    });

    group('regex', () {
      test('should validate matching pattern', () {
        final validator = ValidatorUtils.regex(RegExp(r'^[A-Z]+$'));
        expect(validator.validate('ABC'), isNull);
      });

      test('should reject non-matching pattern', () {
        final validator = ValidatorUtils.regex(RegExp(r'^[A-Z]+$'));
        expect(validator.validate('abc'), isNotNull);
      });

      test('should use custom message', () {
        final validator = ValidatorUtils.regex(
          RegExp(r'^[A-Z]+$'),
          customMessage: 'Solo mayúsculas',
        );
        final result = validator.validate('abc');
        expect(result, 'Solo mayúsculas');
      });
    });
  });
}
