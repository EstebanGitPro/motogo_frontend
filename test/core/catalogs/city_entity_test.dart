import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';

void main() {
  group('CityEntity', () {
    group('constructor', () {
      test('should create entity with required fields', () {
        const entity = CityEntity(id: 'city-001', name: 'Bogotá');

        expect(entity.id, 'city-001');
        expect(entity.name, 'Bogotá');
      });
    });

    group('equality', () {
      test('should be equal when all fields are same', () {
        const entity1 = CityEntity(id: 'city-001', name: 'Bogotá');
        const entity2 = CityEntity(id: 'city-001', name: 'Bogotá');

        expect(entity1, equals(entity2));
      });

      test('should not be equal when id differs', () {
        const entity1 = CityEntity(id: 'city-001', name: 'Bogotá');
        const entity2 = CityEntity(id: 'city-002', name: 'Bogotá');

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when name differs', () {
        const entity1 = CityEntity(id: 'city-001', name: 'Bogotá');
        const entity2 = CityEntity(id: 'city-001', name: 'Medellín');

        expect(entity1, isNot(equals(entity2)));
      });

      test('identical instances should be equal', () {
        const entity = CityEntity(id: 'city-001', name: 'Bogotá');

        expect(entity, equals(entity));
      });
    });

    group('hashCode', () {
      test('equal entities should have same hashCode', () {
        const entity1 = CityEntity(id: 'city-001', name: 'Bogotá');
        const entity2 = CityEntity(id: 'city-001', name: 'Bogotá');

        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('different entities may have different hashCodes', () {
        const entity1 = CityEntity(id: 'city-001', name: 'Bogotá');
        const entity2 = CityEntity(id: 'city-002', name: 'Medellín');

        // Not guaranteed but usually different
        expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        const entity = CityEntity(id: 'city-001', name: 'Bogotá');

        expect(entity.toString(), 'CityEntity(id: city-001, name: Bogotá)');
      });
    });
  });
}
