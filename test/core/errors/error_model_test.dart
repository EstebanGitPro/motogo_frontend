import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

void main() {
  group('ErrorModel', () {
    group('constructor', () {
      test('should create ErrorModel with required message', () {
        // Act
        final error = ErrorModel(message: 'Test error');

        // Assert
        expect(error.message, 'Test error');
        expect(error.description, isNull);
        expect(error.statusCode, isNull);
        expect(error.errorCode, isNull);
        expect(error.details, isNull);
        expect(error.isError, isTrue);
      });

      test('should create ErrorModel with all optional fields', () {
        // Act
        final error = ErrorModel(
          message: 'Test error',
          description: 'Detailed description',
          statusCode: 400,
          errorCode: 'ERR_001',
          details: {'field': 'value'},
          isError: true,
        );

        // Assert
        expect(error.message, 'Test error');
        expect(error.description, 'Detailed description');
        expect(error.statusCode, 400);
        expect(error.errorCode, 'ERR_001');
        expect(error.details, {'field': 'value'});
      });
    });

    group('fromJson', () {
      test('should parse JSON with all fields', () {
        // Arrange
        final json = {
          'message': 'Error message',
          'description': 'Error description',
          'status_code': 404,
          'error_code': 'NOT_FOUND',
          'details': {'field': 'error'},
        };

        // Act
        final error = ErrorModel.fromJson(json);

        // Assert
        expect(error.message, 'Error message');
        expect(error.description, 'Error description');
        expect(error.statusCode, 404);
        expect(error.errorCode, 'NOT_FOUND');
        expect(error.details, {'field': 'error'});
      });

      test('should parse JSON with alternative field names', () {
        // Arrange
        final json = {
          'msg': 'Alternative message',
          'detail': 'Alternative detail',
          'status': 500,
          'code': 'SERVER_ERROR',
          'errors': {'name': 'required'},
        };

        // Act
        final error = ErrorModel.fromJson(json);

        // Assert
        expect(error.message, 'Alternative message');
        expect(error.description, 'Alternative detail');
        expect(error.statusCode, 500);
        expect(error.errorCode, 'SERVER_ERROR');
        expect(error.details, {'name': 'required'});
      });

      test('should use default message when missing', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final error = ErrorModel.fromJson(json);

        // Assert
        expect(error.message, 'Error desconocido');
      });

      test('should prefer message over msg', () {
        // Arrange
        final json = {'message': 'Primary message', 'msg': 'Secondary message'};

        // Act
        final error = ErrorModel.fromJson(json);

        // Assert
        expect(error.message, 'Primary message');
      });
    });

    group('toJson', () {
      test('should serialize all non-null fields', () {
        // Arrange
        final error = ErrorModel(
          message: 'Test error',
          description: 'Description',
          statusCode: 400,
          errorCode: 'ERR_001',
          details: {'field': 'error'},
        );

        // Act
        final json = error.toJson();

        // Assert
        expect(json['message'], 'Test error');
        expect(json['description'], 'Description');
        expect(json['status_code'], 400);
        expect(json['error_code'], 'ERR_001');
        expect(json['details'], {'field': 'error'});
      });

      test('should omit null fields', () {
        // Arrange
        final error = ErrorModel(message: 'Test error');

        // Act
        final json = error.toJson();

        // Assert
        expect(json['message'], 'Test error');
        expect(json.containsKey('description'), isFalse);
        expect(json.containsKey('status_code'), isFalse);
        expect(json.containsKey('error_code'), isFalse);
        expect(json.containsKey('details'), isFalse);
      });
    });

    group('displayMessage', () {
      test('should return description when available', () {
        // Arrange
        final error = ErrorModel(
          message: 'Error',
          description: 'Detailed description',
        );

        // Assert
        expect(error.displayMessage, 'Detailed description');
      });

      test('should return message when description is null', () {
        // Arrange
        final error = ErrorModel(message: 'Error message');

        // Assert
        expect(error.displayMessage, 'Error message');
      });
    });

    group('isValidationError', () {
      test('should return true for VALIDATION_ prefixed codes', () {
        // Arrange
        final error = ErrorModel(
          message: 'Validation error',
          errorCode: 'VALIDATION_REQUIRED',
        );

        // Assert
        expect(error.isValidationError, isTrue);
      });

      test('should return false for non-validation codes', () {
        // Arrange
        final error = ErrorModel(
          message: 'Server error',
          errorCode: 'SERVER_ERROR',
        );

        // Assert
        expect(error.isValidationError, isFalse);
      });

      test('should return false when errorCode is null', () {
        // Arrange
        final error = ErrorModel(message: 'Error');

        // Assert
        expect(error.isValidationError, isFalse);
      });
    });

    group('fieldErrors', () {
      test('should extract field errors from Map details', () {
        // Arrange
        final error = ErrorModel(
          message: 'Validation error',
          details: {'email': 'Invalid format', 'password': 'Too short'},
        );

        // Act
        final fieldErrors = error.fieldErrors;

        // Assert
        expect(fieldErrors, isNotNull);
        expect(fieldErrors!['email'], 'Invalid format');
        expect(fieldErrors['password'], 'Too short');
      });

      test('should join List values into comma-separated string', () {
        // Arrange
        final error = ErrorModel(
          message: 'Validation error',
          details: {
            'email': ['Invalid format', 'Already exists'],
          },
        );

        // Act
        final fieldErrors = error.fieldErrors;

        // Assert
        expect(fieldErrors, isNotNull);
        expect(fieldErrors!['email'], 'Invalid format, Already exists');
      });

      test('should return null when details is null', () {
        // Arrange
        final error = ErrorModel(message: 'Error');

        // Assert
        expect(error.fieldErrors, isNull);
      });

      test('should return null when details is empty', () {
        // Arrange
        final error = ErrorModel(message: 'Error', details: {});

        // Assert
        expect(error.fieldErrors, isNull);
      });
    });
  });
}
