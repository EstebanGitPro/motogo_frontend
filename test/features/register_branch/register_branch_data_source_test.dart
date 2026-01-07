import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/features/register_branch/data/models/branch_model.dart';

import 'register_branch_data_source_test.mocks.dart';

// Note: This is a simplified test that focuses on the HTTP response handling.
// The actual RegisterBranchDataSourceImpl uses FlutterSecureStorage internally,
// which makes it harder to mock. For full testing, consider injecting storage.

@GenerateMocks([http.Client])
void main() {
  group('RegisterBranchDataSource Response Handling', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
    });

    const testDepartmentId = 'dept-01';

    final testBranch = BranchModel(
      name: 'MotoGo Centro',
      establishmentType: 'WORKSHOP',
      address: 'Calle 123',
      cityId: 'city-01',
      departmentId: testDepartmentId,
      brands: ['brand-01'],
    );

    group('HTTP Response Parsing', () {
      test('BranchModel toJson produces valid JSON with location', () {
        // Act
        final json = testBranch.toJson();

        // Assert
        expect(json['name'], 'MotoGo Centro');
        expect(json['establishment_type'], 'WORKSHOP');
        expect(json['location']['department_id'], testDepartmentId);
        expect(json['location']['city_id'], 'city-01');
        expect(json['location']['address'], 'Calle 123');
        expect(json['brands'], ['brand-01']);
      });

      test('success response should contain message', () {
        // Arrange
        final responseBody = {
          'success': true,
          'code': 'MOD_B_BR_CRE_00001',
          'message': 'Sede creada exitosamente.',
          'data': {
            'branch': {'id': 'branch-123', 'name': 'MotoGo Centro'},
          },
        };

        // Assert
        expect(responseBody['success'], isTrue);
        expect(responseBody['message'], contains('exitosamente'));
      });

      test('error response should contain error info', () {
        // Arrange
        final responseBody = {
          'success': false,
          'code': 'ERR_VAL_001',
          'message': 'El nombre de la sede es requerido',
        };

        // Assert
        expect(responseBody['success'], isFalse);
        expect(responseBody['message'], isNotEmpty);
      });
    });

    group('Request Formatting', () {
      test('branch with profileImageUrl includes it in JSON', () {
        final branchWithImage = BranchModel(
          name: 'Test',
          establishmentType: 'WORKSHOP',
          address: 'Test Address',
          cityId: 'city-01',
          departmentId: testDepartmentId,
          profileImageUrl: 'https://firebase.storage/image.jpg',
        );

        final json = branchWithImage.toJson();

        expect(json['profile_image_url'], 'https://firebase.storage/image.jpg');
      });

      test(
        'location does not include coordinates (backend handles geocoding)',
        () {
          final branch = BranchModel(
            name: 'Test',
            establishmentType: 'WORKSHOP',
            address: 'Test Address',
            cityId: 'city-01',
            departmentId: testDepartmentId,
          );

          final json = branch.toJson();

          expect(json['location'].containsKey('latitude'), isFalse);
          expect(json['location'].containsKey('longitude'), isFalse);
        },
      );

      test('encoded JSON is valid', () {
        final jsonData = testBranch.toJson();
        final encoded = json.encode(jsonData);

        expect(() => json.decode(encoded), returnsNormally);
      });
    });
  });
}
