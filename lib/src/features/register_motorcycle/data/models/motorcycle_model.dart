import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Data model for motorcycle serialization/deserialization.
///
/// Handles JSON conversion for the POST /motorcycles endpoint.
class MotorcycleModel extends MotorcycleEntity {
  const MotorcycleModel({
    super.id,
    required super.licensePlate,
    super.year,
    super.currentMileage,
    super.ownerNotes,
  });

  /// Creates a model from a domain entity.
  factory MotorcycleModel.fromEntity(MotorcycleEntity entity) {
    return MotorcycleModel(
      id: entity.id,
      licensePlate: entity.licensePlate,
      year: entity.year,
      currentMileage: entity.currentMileage,
      ownerNotes: entity.ownerNotes,
    );
  }

  /// Creates a model from JSON response.
  ///
  /// The API returns the created motorcycle with an ID.
  factory MotorcycleModel.fromJson(Map<String, dynamic> json) {
    return MotorcycleModel(
      id: json['id']?.toString(),
      licensePlate: json['license_plate'] ?? '',
      year: json['year'] as int?,
      currentMileage: json['current_mileage'] as int?,
      ownerNotes: json['owner_notes']?.toString(),
    );
  }

  /// Converts the model to JSON for API requests.
  ///
  /// Only includes non-null fields to avoid sending unnecessary data.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {'license_plate': licensePlate};

    if (year != null) {
      json['year'] = year;
    }

    if (currentMileage != null) {
      json['current_mileage'] = currentMileage;
    }

    if (ownerNotes != null && ownerNotes!.isNotEmpty) {
      json['owner_notes'] = ownerNotes;
    }

    return json;
  }

  /// Converts the model to a domain entity.
  MotorcycleEntity toEntity() {
    return MotorcycleEntity(
      id: id,
      licensePlate: licensePlate,
      year: year,
      currentMileage: currentMileage,
      ownerNotes: ownerNotes,
    );
  }

  @override
  MotorcycleModel copyWith({
    String? id,
    String? licensePlate,
    int? year,
    int? currentMileage,
    String? ownerNotes,
  }) {
    return MotorcycleModel(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      year: year ?? this.year,
      currentMileage: currentMileage ?? this.currentMileage,
      ownerNotes: ownerNotes ?? this.ownerNotes,
    );
  }
}
