import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/geocoding/data/models/geocoding_result_model.dart';

void main() {
  group('GeocodingResultModel', () {
    group('fromJson', () {
      test('should create model from JSON with nested data object', () {
        final json = {
          'data': {
            'latitude': 4.6097,
            'longitude': -74.0817,
            'formatted_address': 'Calle 100 #15-20, Bogotá',
            'confidence': 0.95,
            'geocoded': true,
          },
        };

        final model = GeocodingResultModel.fromJson(json);

        expect(model.latitude, 4.6097);
        expect(model.longitude, -74.0817);
        expect(model.formattedAddress, 'Calle 100 #15-20, Bogotá');
        expect(model.confidence, 0.95);
        expect(model.geocoded, true);
      });

      test('should create model from flat JSON without data wrapper', () {
        final json = {
          'latitude': 6.2442,
          'longitude': -75.5812,
          'formatted_address': 'Carrera 43A #1-50, Medellín',
          'confidence': 0.88,
          'geocoded': true,
        };

        final model = GeocodingResultModel.fromJson(json);

        expect(model.latitude, 6.2442);
        expect(model.longitude, -75.5812);
        expect(model.formattedAddress, 'Carrera 43A #1-50, Medellín');
        expect(model.confidence, 0.88);
        expect(model.geocoded, true);
      });

      test('should handle null values with defaults', () {
        final json = <String, dynamic>{};

        final model = GeocodingResultModel.fromJson(json);

        expect(model.latitude, 0.0);
        expect(model.longitude, 0.0);
        expect(model.formattedAddress, '');
        expect(model.confidence, 0.0);
        expect(model.geocoded, false);
      });

      test('should handle integer coordinates by converting to double', () {
        final json = {
          'latitude': 4,
          'longitude': -74,
          'formatted_address': 'Test',
          'confidence': 1,
          'geocoded': true,
        };

        final model = GeocodingResultModel.fromJson(json);

        expect(model.latitude, 4.0);
        expect(model.longitude, -74.0);
        expect(model.confidence, 1.0);
      });
    });

    group('toJson', () {
      test('should serialize model to JSON map', () {
        const model = GeocodingResultModel(
          latitude: 3.4516,
          longitude: -76.5320,
          formattedAddress: 'Calle 5 #10-30, Cali',
          confidence: 0.92,
          geocoded: true,
        );

        final json = model.toJson();

        expect(json['latitude'], 3.4516);
        expect(json['longitude'], -76.5320);
        expect(json['formatted_address'], 'Calle 5 #10-30, Cali');
        expect(json['confidence'], 0.92);
        expect(json['geocoded'], true);
      });
    });

    group('isValid', () {
      test('should return true when geocoded with valid coordinates', () {
        const model = GeocodingResultModel(
          latitude: 4.6097,
          longitude: -74.0817,
          formattedAddress: 'Bogotá',
          confidence: 0.9,
          geocoded: true,
        );

        expect(model.isValid, true);
      });

      test('should return false when geocoded is false', () {
        const model = GeocodingResultModel(
          latitude: 4.6097,
          longitude: -74.0817,
          formattedAddress: 'Bogotá',
          confidence: 0.9,
          geocoded: false,
        );

        expect(model.isValid, false);
      });

      test('should return false when latitude is 0.0', () {
        const model = GeocodingResultModel(
          latitude: 0.0,
          longitude: -74.0817,
          formattedAddress: 'Test',
          confidence: 0.9,
          geocoded: true,
        );

        expect(model.isValid, false);
      });

      test('should return false when longitude is 0.0', () {
        const model = GeocodingResultModel(
          latitude: 4.6097,
          longitude: 0.0,
          formattedAddress: 'Test',
          confidence: 0.9,
          geocoded: true,
        );

        expect(model.isValid, false);
      });

      test('should return false when both coordinates are 0.0', () {
        const model = GeocodingResultModel(
          latitude: 0.0,
          longitude: 0.0,
          formattedAddress: '',
          confidence: 0.0,
          geocoded: true,
        );

        expect(model.isValid, false);
      });
    });
  });
}
