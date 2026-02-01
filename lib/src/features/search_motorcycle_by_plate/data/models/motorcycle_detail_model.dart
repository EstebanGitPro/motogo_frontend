import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';

/// Model for motorcycle reference info from API response.
class MotorcycleReferenceInfoModel {
  final String brandName;
  final String model;
  final String category;
  final int engineDisplacementCc;

  const MotorcycleReferenceInfoModel({
    required this.brandName,
    required this.model,
    required this.category,
    required this.engineDisplacementCc,
  });

  factory MotorcycleReferenceInfoModel.fromJson(Map<String, dynamic> json) {
    return MotorcycleReferenceInfoModel(
      brandName: json['brand_name']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      engineDisplacementCc:
          (json['engine_displacement_cc'] as num?)?.toInt() ?? 0,
    );
  }

  MotorcycleReferenceInfoEntity toEntity() {
    return MotorcycleReferenceInfoEntity(
      brandName: brandName,
      model: model,
      category: category,
      engineDisplacementCc: engineDisplacementCc,
    );
  }
}

/// Data model for motorcycle detail from plate lookup.
///
/// Handles JSON conversion for the GET /motorcycles/lookup endpoint (HU47).
class MotorcycleDetailModel {
  final String id;
  final String licensePlate;
  final int year;
  final int currentMileage;
  final MotorcycleReferenceInfoModel reference;

  const MotorcycleDetailModel({
    required this.id,
    required this.licensePlate,
    required this.year,
    required this.currentMileage,
    required this.reference,
  });

  /// Creates a model from JSON response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "license_plate": "MRC35E",
  ///   "year": 2027,
  ///   "current_mileage": 5000,
  ///   "reference": {
  ///     "brand_name": "Suzuki",
  ///     "model": "Gixxer 250",
  ///     "category": "Sport",
  ///     "engine_displacement_cc": 249
  ///   }
  /// }
  /// ```
  factory MotorcycleDetailModel.fromJson(Map<String, dynamic> json) {
    return MotorcycleDetailModel(
      id: json['id']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? '',
      year: (json['year'] as num?)?.toInt() ?? 0,
      currentMileage: (json['current_mileage'] as num?)?.toInt() ?? 0,
      reference: MotorcycleReferenceInfoModel.fromJson(
        json['reference'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  /// Converts the model to a domain entity.
  MotorcycleDetailEntity toEntity() {
    return MotorcycleDetailEntity(
      id: id,
      licensePlate: licensePlate,
      year: year,
      currentMileage: currentMileage,
      reference: reference.toEntity(),
    );
  }
}
