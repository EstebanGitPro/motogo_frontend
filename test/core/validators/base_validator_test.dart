import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/validation_messages.dart';
import 'package:motogo_frontend/src/core/validators/base_validator.dart';

void main() {
  group('BaseValidator', () {
    group('RequiredValidator', () {
      test('should return null for non-empty value', () {
        const validator = RequiredValidator();
        expect(validator.validate('value'), isNull);
      });

      test('should return error for empty string', () {
        const validator = RequiredValidator();
        expect(
          validator.validate(''),
          equals(ValidationMessages.requiredField),
        );
      });

      test('should return error for null', () {
        const validator = RequiredValidator();
        expect(
          validator.validate(null),
          equals(ValidationMessages.requiredField),
        );
      });

      test('should return error for whitespace only', () {
        const validator = RequiredValidator();
        expect(
          validator.validate('   '),
          equals(ValidationMessages.requiredField),
        );
      });

      test('should use custom message', () {
        const validator = RequiredValidator(customMessage: 'Campo obligatorio');
        expect(validator.validate(''), equals('Campo obligatorio'));
      });
    });

    group('MinLengthValidator', () {
      test('should return null when length meets minimum', () {
        const validator = MinLengthValidator(5);
        expect(validator.validate('hello'), isNull);
      });

      test('should return null when length exceeds minimum', () {
        const validator = MinLengthValidator(5);
        expect(validator.validate('hello world'), isNull);
      });

      test('should return error when below minimum', () {
        const validator = MinLengthValidator(5);
        final result = validator.validate('hi');
        expect(result, contains('5'));
      });

      test('should return error for null', () {
        const validator = MinLengthValidator(5);
        expect(validator.validate(null), isNotNull);
      });

      test('should use custom message', () {
        const validator = MinLengthValidator(5, customMessage: 'Muy corto');
        expect(validator.validate('hi'), equals('Muy corto'));
      });
    });

    group('MaxLengthValidator', () {
      test('should return null when length is within maximum', () {
        const validator = MaxLengthValidator(10);
        expect(validator.validate('hello'), isNull);
      });

      test('should return null when length equals maximum', () {
        const validator = MaxLengthValidator(5);
        expect(validator.validate('hello'), isNull);
      });

      test('should return error when exceeds maximum', () {
        const validator = MaxLengthValidator(5);
        final result = validator.validate('hello world');
        expect(result, contains('5'));
      });

      test('should return null for null input', () {
        const validator = MaxLengthValidator(5);
        expect(validator.validate(null), isNull);
      });

      test('should use custom message', () {
        const validator = MaxLengthValidator(5, customMessage: 'Muy largo');
        expect(validator.validate('hello world'), equals('Muy largo'));
      });
    });

    group('RegexValidator', () {
      test('should return null when pattern matches', () {
        final validator = RegexValidator(RegExp(r'^[A-Z]+$'));
        expect(validator.validate('ABC'), isNull);
      });

      test('should return error when pattern does not match', () {
        final validator = RegexValidator(RegExp(r'^[A-Z]+$'));
        expect(validator.validate('abc'), isNotNull);
      });

      test('should return null for null input', () {
        final validator = RegexValidator(RegExp(r'^[A-Z]+$'));
        expect(validator.validate(null), isNull);
      });

      test('should use custom message', () {
        final validator = RegexValidator(
          RegExp(r'^[A-Z]+$'),
          customMessage: 'Solo mayúsculas',
        );
        expect(validator.validate('abc'), equals('Solo mayúsculas'));
      });
    });

    group('ValidatorComposer', () {
      test('should return null when all validators pass', () {
        const composer = ValidatorComposer([
          RequiredValidator(),
          MinLengthValidator(3),
        ]);
        expect(composer.validate('hello'), isNull);
      });

      test('should return first error found', () {
        const composer = ValidatorComposer([
          RequiredValidator(),
          MinLengthValidator(10),
        ]);
        final result = composer.validate('hi');
        expect(result, contains('10'));
      });

      test('should return required error for empty value', () {
        const composer = ValidatorComposer([
          RequiredValidator(),
          MinLengthValidator(3),
        ]);
        expect(composer.validate(''), equals(ValidationMessages.requiredField));
      });

      test('should handle empty validators list', () {
        const composer = ValidatorComposer([]);
        expect(composer.validate('anything'), isNull);
      });

      test('should chain multiple validators correctly', () {
        final composer = ValidatorComposer([
          const RequiredValidator(),
          const MinLengthValidator(2),
          const MaxLengthValidator(10),
          RegexValidator(RegExp(r'^[a-zA-Z]+$')),
        ]);

        expect(composer.validate('Hello'), isNull);
        expect(composer.validate(''), isNotNull); // Required
        expect(composer.validate('a'), isNotNull); // MinLength
        expect(composer.validate('HelloWorldTooLong'), isNotNull); // MaxLength
        expect(composer.validate('Hello123'), isNotNull); // Regex
      });
    });

    group('getMessage', () {
      test('should return custom message when provided', () {
        const validator = RequiredValidator(customMessage: 'Custom');
        expect(validator.validate(''), equals('Custom'));
      });

      test('should return default message when no custom message', () {
        const validator = RequiredValidator();
        expect(
          validator.validate(''),
          equals(ValidationMessages.requiredField),
        );
      });
    });
  });
}
