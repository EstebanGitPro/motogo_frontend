import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/day_model.dart';

void main() {
  group('DayModel', () {
    group('fromJson', () {
      test('should correctly parse complete JSON', () {
        // Arrange
        final json = {'value': 'monday', 'label': 'Lunes'};

        // Act
        final result = DayModel.fromJson(json);

        // Assert
        expect(result.value, equals('monday'));
        expect(result.label, equals('Lunes'));
      });

      test('should handle null values with defaults', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final result = DayModel.fromJson(json);

        // Assert
        expect(result.value, equals(''));
        expect(result.label, equals(''));
      });

      test('should handle all days of the week', () {
        final days = [
          {'value': 'monday', 'label': 'Lunes'},
          {'value': 'tuesday', 'label': 'Martes'},
          {'value': 'wednesday', 'label': 'Miércoles'},
          {'value': 'thursday', 'label': 'Jueves'},
          {'value': 'friday', 'label': 'Viernes'},
          {'value': 'saturday', 'label': 'Sábado'},
          {'value': 'sunday', 'label': 'Domingo'},
        ];

        for (final day in days) {
          final result = DayModel.fromJson(day);
          expect(result.value, equals(day['value']));
          expect(result.label, equals(day['label']));
        }
      });
    });

    group('toJson', () {
      test('should correctly serialize to JSON', () {
        // Arrange
        const model = DayModel(value: 'monday', label: 'Lunes');

        // Act
        final result = model.toJson();

        // Assert
        expect(result['value'], equals('monday'));
        expect(result['label'], equals('Lunes'));
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        const model1 = DayModel(value: 'monday', label: 'Lunes');
        const model2 = DayModel(value: 'monday', label: 'Lunes');

        // Assert
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        const model1 = DayModel(value: 'monday', label: 'Lunes');
        const model2 = DayModel(value: 'tuesday', label: 'Martes');

        // Assert
        expect(model1, isNot(equals(model2)));
      });
    });
  });
}
