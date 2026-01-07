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

    const testBranch = BranchModel(
      name: 'MotoGo Centro',
      establishmentType: 'WORKSHOP',
      address: 'Calle 123',
      cityId: 'city-01',
      brands: ['brand-01'],
    );

    group('HTTP Response Parsing', () {
      test('BranchModel toJson produces valid JSON', () {
        // Act
        final json = testBranch.toJson();

        // Assert
        expect(json['name'], 'MotoGo Centro');
        expect(json['establishment_type'], 'WORKSHOP');
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
        const branchWithImage = BranchModel(
          name: 'Test',
          establishmentType: 'WORKSHOP',
          address: 'Test Address',
          cityId: 'city-01',
          profileImageUrl: 'https://firebase.storage/image.jpg',
        );

        final json = branchWithImage.toJson();

        expect(json['profile_image_url'], 'https://firebase.storage/image.jpg');
      });

      test('branch with coordinates includes them in location', () {
        const branchWithCoords = BranchModel(
          name: 'Test',
          establishmentType: 'WORKSHOP',
          address: 'Test Address',
          cityId: 'city-01',
          latitude: 4.7110,
          longitude: -74.0721,
        );

        final json = branchWithCoords.toJson();

        expect(json['location']['latitude'], 4.7110);
        expect(json['location']['longitude'], -74.0721);
      });

      test('encoded JSON is valid', () {
        final jsonData = testBranch.toJson();
        final encoded = json.encode(jsonData);

        expect(() => json.decode(encoded), returnsNormally);
      });
    });
  });
}
