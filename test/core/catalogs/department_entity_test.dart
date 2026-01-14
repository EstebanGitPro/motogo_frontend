import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';

void main() {
  group('DepartmentEntity', () {
    group('constructor', () {
      test('should create entity with required fields', () {
        const entity = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');

        expect(entity.id, 'dept-001');
        expect(entity.name, 'Cundinamarca');
      });
    });

    group('equality', () {
      test('should be equal when all fields are same', () {
        const entity1 = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');
        const entity2 = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');

        expect(entity1, equals(entity2));
      });

      test('should not be equal when id differs', () {
        const entity1 = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');
        const entity2 = DepartmentEntity(id: 'dept-002', name: 'Cundinamarca');

        expect(entity1, isNot(equals(entity2)));
      });

      test('should not be equal when name differs', () {
        const entity1 = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');
        const entity2 = DepartmentEntity(id: 'dept-001', name: 'Antioquia');

        expect(entity1, isNot(equals(entity2)));
      });

      test('identical instances should be equal', () {
        const entity = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');

        expect(entity, equals(entity));
      });
    });

    group('hashCode', () {
      test('equal entities should have same hashCode', () {
        const entity1 = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');
        const entity2 = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');

        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('different entities may have different hashCodes', () {
        const entity1 = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');
        const entity2 = DepartmentEntity(id: 'dept-002', name: 'Antioquia');

        expect(entity1.hashCode, isNot(equals(entity2.hashCode)));
      });
    });

    group('toString', () {
      test('should return formatted string', () {
        const entity = DepartmentEntity(id: 'dept-001', name: 'Cundinamarca');

        expect(
          entity.toString(),
          'DepartmentEntity(id: dept-001, name: Cundinamarca)',
        );
      });
    });
  });
}
