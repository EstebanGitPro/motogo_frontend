import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/validation_messages.dart';

void main() {
  group('ValidationMessages', () {
    group('static constants', () {
      test('should have correct required field message', () {
        expect(ValidationMessages.requiredField, 'Este campo es requerido');
      });

      test('should have correct email validation messages', () {
        expect(
          ValidationMessages.invalidEmail,
          'Ingresa un correo electrónico válido',
        );
        expect(
          ValidationMessages.emailRequired,
          'El correo electrónico es requerido',
        );
      });

      test('should have correct password validation messages', () {
        expect(
          ValidationMessages.passwordRequired,
          'La contraseña es requerida',
        );
        expect(
          ValidationMessages.passwordMinLength,
          'La contraseña debe tener al menos 8 caracteres',
        );
        expect(
          ValidationMessages.passwordUppercase,
          'Debe contener al menos una mayúscula',
        );
        expect(
          ValidationMessages.passwordLowercase,
          'Debe contener al menos una minúscula',
        );
        expect(
          ValidationMessages.passwordNumber,
          'Debe contener al menos un número',
        );
        expect(
          ValidationMessages.passwordSpecialChar,
          'Debe contener al menos un carácter especial',
        );
        expect(
          ValidationMessages.passwordMismatch,
          'Las contraseñas no coinciden',
        );
      });
    });

    group('dynamic methods', () {
      test('minLengthWithValue should return formatted message', () {
        expect(ValidationMessages.minLengthWithValue(5), 'Mínimo 5 caracteres');
        expect(
          ValidationMessages.minLengthWithValue(10),
          'Mínimo 10 caracteres',
        );
      });

      test('maxLengthWithValue should return formatted message', () {
        expect(
          ValidationMessages.maxLengthWithValue(20),
          'Máximo 20 caracteres',
        );
        expect(
          ValidationMessages.maxLengthWithValue(100),
          'Máximo 100 caracteres',
        );
      });

      test('exactLengthWithValue should return formatted message', () {
        expect(
          ValidationMessages.exactLengthWithValue(8),
          'Debe tener exactamente 8 caracteres',
        );
        expect(
          ValidationMessages.exactLengthWithValue(11),
          'Debe tener exactamente 11 caracteres',
        );
      });

      test('rangeLength should return formatted message', () {
        expect(
          ValidationMessages.rangeLength(5, 20),
          'Debe tener entre 5 y 20 caracteres',
        );
        expect(
          ValidationMessages.rangeLength(10, 50),
          'Debe tener entre 10 y 50 caracteres',
        );
      });
    });
  });
}
