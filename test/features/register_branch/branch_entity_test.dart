import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

void main() {
  group('BranchEntity', () {
    const testId = 'branch-001';
    const testName = 'MotoGo Centro';
    const testEstablishmentType = 'WORKSHOP';
    const testAddress = 'Calle 123';
    const testCityId = 'city-001';
    const testCityName = 'Bogotá';
    const testDepartmentId = 'dept-001';
    const testDepartmentName = 'Cundinamarca';

    group('constructor', () {
      test('should create entity with required fields', () {
        const entity = BranchEntity(
          name: testName,
          establishmentType: testEstablishmentType,
          address: testAddress,
          cityId: testCityId,
          departmentId: testDepartmentId,
        );

        expect(entity.name, testName);
        expect(entity.establishmentType, testEstablishmentType);
        expect(entity.address, testAddress);
        expect(entity.cityId, testCityId);
        expect(entity.departmentId, testDepartmentId);
      });

      test('should have default status as ACTIVE', () {
        const entity = BranchEntity(
          name: testName,
          establishmentType: testEstablishmentType,
          address: testAddress,
          cityId: testCityId,
          departmentId: testDepartmentId,
        );

        expect(entity.status, BranchStatus.active);
      });

      test('should have empty brands list by default', () {
        const entity = BranchEntity(
          name: testName,
          establishmentType: testEstablishmentType,
          address: testAddress,
          cityId: testCityId,
          departmentId: testDepartmentId,
        );

        expect(entity.brands, isEmpty);
      });

      test('should create entity with all optional fields', () {
        const entity = BranchEntity(
          id: testId,
          name: testName,
          establishmentType: testEstablishmentType,
          franchiseId: 'franchise-001',
          profileImageUrl: 'https://example.com/image.jpg',
          status: BranchStatus.inactive,
          brands: ['brand-1', 'brand-2'],
          address: testAddress,
          cityId: testCityId,
          cityName: testCityName,
          departmentId: testDepartmentId,
          departmentName: testDepartmentName,
        );

        expect(entity.id, testId);
        expect(entity.franchiseId, 'franchise-001');
        expect(entity.profileImageUrl, 'https://example.com/image.jpg');
        expect(entity.status, BranchStatus.inactive);
        expect(entity.brands.length, 2);
        expect(entity.cityName, testCityName);
        expect(entity.departmentName, testDepartmentName);
      });
    });

    group('copyWith', () {
      test('should copy with updated fields', () {
        const original = BranchEntity(
          id: testId,
          name: testName,
          establishmentType: testEstablishmentType,
          address: testAddress,
          cityId: testCityId,
          departmentId: testDepartmentId,
        );

        final copied = original.copyWith(
          name: 'Updated Name',
          status: BranchStatus.inactive,
        );

        expect(copied.name, 'Updated Name');
        expect(copied.status, BranchStatus.inactive);
        expect(copied.id, testId);
        expect(copied.address, testAddress);
      });

      test('should return same values when no arguments', () {
        const original = BranchEntity(
          id: testId,
          name: testName,
          establishmentType: testEstablishmentType,
          address: testAddress,
          cityId: testCityId,
          departmentId: testDepartmentId,
        );

        final copied = original.copyWith();

        expect(copied.id, original.id);
        expect(copied.name, original.name);
        expect(copied.address, original.address);
      });

      test('should update all fields correctly', () {
        const original = BranchEntity(
          name: testName,
          establishmentType: testEstablishmentType,
          address: testAddress,
          cityId: testCityId,
          departmentId: testDepartmentId,
        );

        final copied = original.copyWith(
          id: 'new-id',
          name: 'New Name',
          establishmentType: 'PARTS_STORE',
          franchiseId: 'new-franchise',
          profileImageUrl: 'https://new-url.com',
          status: BranchStatus.inactive,
          brands: ['brand-new'],
          address: 'New Address',
          cityId: 'new-city',
          cityName: 'New City',
          departmentId: 'new-dept',
          departmentName: 'New Department',
        );

        expect(copied.id, 'new-id');
        expect(copied.name, 'New Name');
        expect(copied.establishmentType, 'PARTS_STORE');
        expect(copied.franchiseId, 'new-franchise');
        expect(copied.profileImageUrl, 'https://new-url.com');
        expect(copied.status, BranchStatus.inactive);
        expect(copied.brands, ['brand-new']);
        expect(copied.address, 'New Address');
        expect(copied.cityId, 'new-city');
        expect(copied.cityName, 'New City');
        expect(copied.departmentId, 'new-dept');
        expect(copied.departmentName, 'New Department');
      });
    });
  });

  group('BranchStatus', () {
    test('should have active constant', () {
      expect(BranchStatus.active, 'ACTIVE');
    });

    test('should have inactive constant', () {
      expect(BranchStatus.inactive, 'INACTIVE');
    });

    test('should have values list with both statuses', () {
      expect(BranchStatus.values.length, 2);
      expect(BranchStatus.values.contains('ACTIVE'), isTrue);
      expect(BranchStatus.values.contains('INACTIVE'), isTrue);
    });
  });
}
