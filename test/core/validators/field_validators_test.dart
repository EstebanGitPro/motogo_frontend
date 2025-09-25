import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/validation_messages.dart';
import 'package:motogo_frontend/src/core/validators/validators.dart';

void main() {
  group('EmailValidator', () {
    late EmailValidator validator;

    setUp(() {
      validator = const EmailValidator();
    });

    test('should return null for valid email', () {
      expect(validator.validate('test@example.com'), isNull);
      expect(validator.validate('user.name@domain.co'), isNull);
    });

    test('should return error for empty email', () {
      expect(validator.validate(''), ValidationMessages.emailRequired);
      expect(validator.validate(null), ValidationMessages.emailRequired);
    });

    test('should return error for invalid email format', () {
      expect(validator.validate('invalid-email'), ValidationMessages.invalidEmail);
      expect(validator.validate('test@'), ValidationMessages.invalidEmail);
      expect(validator.validate('@domain.com'), ValidationMessages.invalidEmail);
    });

    test('should use custom message when provided', () {
      const customMessage = 'Email inválido personalizado';
      final customValidator = EmailValidator(customMessage: customMessage);
      expect(customValidator.validate('invalid'), customMessage);
    });
  });

  group('PasswordValidator', () {
    late PasswordValidator validator;

    setUp(() {
      validator = const PasswordValidator();
    });

    test('should return null for valid password', () {
      expect(validator.validate('Password123'), isNull);
    });

    test('should return error for empty password', () {
      expect(validator.validate(''), ValidationMessages.passwordRequired);
      expect(validator.validate(null), ValidationMessages.passwordRequired);
    });

    test('should return error for short password', () {
      expect(validator.validate('Pass123'), ValidationMessages.passwordMinLength);
    });

    test('should return error for missing uppercase', () {
      expect(validator.validate('password123'), ValidationMessages.passwordUppercase);
    });

    test('should return error for missing lowercase', () {
      expect(validator.validate('PASSWORD123'), ValidationMessages.passwordLowercase);
    });

    test('should return error for missing number', () {
      expect(validator.validate('Password'), ValidationMessages.passwordNumber);
    });

    test('should validate with custom requirements', () {
      final customValidator = PasswordValidator(
        minLength: 6,
        requireUppercase: false,
        requireLowercase: false,
        requireNumber: false,
      );
      expect(customValidator.validate('pass'), ValidationMessages.passwordMinLength);
      expect(customValidator.validate('password'), isNull);
    });
  });

  group('NameValidator', () {
    late NameValidator validator;

    setUp(() {
      validator = const NameValidator();
    });

    test('should return null for valid name', () {
      expect(validator.validate('John'), isNull);
      expect(validator.validate('María José'), isNull);
      expect(validator.validate('José'), isNull);
    });

    test('should return error for empty name', () {
      expect(validator.validate(''), ValidationMessages.nameRequired);
      expect(validator.validate(null), ValidationMessages.nameRequired);
    });

    test('should return error for short name', () {
      expect(validator.validate('A'), ValidationMessages.nameMinLength);
    });

    test('should return error for invalid characters', () {
      expect(validator.validate('John123'), ValidationMessages.nameInvalid);
      expect(validator.validate('John@Doe'), ValidationMessages.nameInvalid);
    });

    test('should validate length constraints', () {
      final customValidator = NameValidator(minLength: 3, maxLength: 10);
      expect(customValidator.validate('Jo'), 'Mínimo 3 caracteres');
      expect(customValidator.validate('VeryLongName'), 'Máximo 10 caracteres');
    });
  });

  group('IdentityValidator', () {
    late IdentityValidator validator;

    setUp(() {
      validator = const IdentityValidator();
    });

    test('should return null for valid identity number', () {
      expect(validator.validate('1234567890'), isNull);
      expect(validator.validate('1234567'), isNull);
    });

    test('should return error for empty identity', () {
      expect(validator.validate(''), ValidationMessages.identityRequired);
      expect(validator.validate(null), ValidationMessages.identityRequired);
    });

    test('should return error for non-numeric identity', () {
      expect(validator.validate('12345abc'), ValidationMessages.identityInvalid);
      expect(validator.validate('abcdef'), ValidationMessages.identityInvalid);
    });

    test('should return error for short identity', () {
      expect(validator.validate('123456'), 'Mínimo 7 caracteres');
    });

    test('should validate custom length constraints', () {
      final customValidator = IdentityValidator(minLength: 5, maxLength: 8);
      expect(customValidator.validate('1234'), 'Mínimo 5 caracteres');
      expect(customValidator.validate('123456789'), 'Máximo 8 caracteres');
    });
  });

  group('PhoneValidator', () {
    late PhoneValidator validator;

    setUp(() {
      validator = const PhoneValidator();
    });

    test('should return null for valid phone numbers', () {
      expect(validator.validate('1234567890'), isNull);
      expect(validator.validate('+1234567890123'), isNull);
    });

    test('should return error for empty phone', () {
      expect(validator.validate(''), ValidationMessages.phoneRequired);
      expect(validator.validate(null), ValidationMessages.phoneRequired);
    });

    test('should return error for invalid phone format', () {
      expect(validator.validate('123'), ValidationMessages.phoneInvalid);
      expect(validator.validate('123-456-7890'), ValidationMessages.phoneInvalid);
      expect(validator.validate('abcdefghij'), ValidationMessages.phoneInvalid);
    });
  });

  group('ConfirmPasswordValidator', () {
    test('should return null when passwords match', () {
      final validator = ConfirmPasswordValidator('password123');
      expect(validator.validate('password123'), isNull);
    });

    test('should return error when passwords do not match', () {
      final validator = ConfirmPasswordValidator('password123');
      expect(validator.validate('different'), ValidationMessages.passwordMismatch);
    });

    test('should return error for empty confirmation', () {
      final validator = ConfirmPasswordValidator('password123');
      expect(validator.validate(''), ValidationMessages.requiredField);
    });
  });

  group('ValidatorComposer', () {
    test('should return null when all validators pass', () {
      final validators = [
        const RequiredValidator(),
        const MinLengthValidator(3),
      ];
      final composer = ValidatorComposer(validators);
      expect(composer.validate('hello'), isNull);
    });

    test('should return first error when any validator fails', () {
      final validators = [
        const RequiredValidator(),
        const MinLengthValidator(10),
      ];
      final composer = ValidatorComposer(validators);
      expect(composer.validate('hi'), ValidationMessages.minLengthWithValue(10));
    });
  });

  group('ValidatorUtils', () {
    test('should create email validator', () {
      final validator = ValidatorUtils.email();
      expect(validator, isA<EmailValidator>());
    });

    test('should create password validator with default settings', () {
      final validator = ValidatorUtils.password();
      expect(validator, isA<PasswordValidator>());
    });

    test('should create composed validator', () {
      final validators = [
        ValidatorUtils.required(),
        ValidatorUtils.minLength(5),
      ];
      final composer = ValidatorUtils.compose(validators);
      expect(composer, isA<ValidatorComposer>());
    });
  });
}
