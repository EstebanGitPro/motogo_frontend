/// Model representing a geocoding result from the backend API.
///
/// Maps to the response from `POST /geocoding/test`
class GeocodingResultModel {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final double confidence;
  final bool geocoded;

  const GeocodingResultModel({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.confidence,
    required this.geocoded,
  });

  factory GeocodingResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return GeocodingResultModel(
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      formattedAddress: data['formatted_address'] as String? ?? '',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      geocoded: data['geocoded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formatted_address': formattedAddress,
      'confidence': confidence,
      'geocoded': geocoded,
    };
  }

  /// Returns true if geocoding was successful with valid coordinates
  bool get isValid => geocoded && latitude != 0.0 && longitude != 0.0;
}
