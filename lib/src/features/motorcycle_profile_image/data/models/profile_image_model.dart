import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/entities/profile_image_entity.dart';

/// Data model for profile image serialization/deserialization.
///
/// Handles JSON conversion for motorcycle profile image endpoints.
class ProfileImageModel extends ProfileImageEntity {
  const ProfileImageModel({required super.motorcycleId, super.profileImageUrl});

  /// Creates a model from a domain entity.
  factory ProfileImageModel.fromEntity(ProfileImageEntity entity) {
    return ProfileImageModel(
      motorcycleId: entity.motorcycleId,
      profileImageUrl: entity.profileImageUrl,
    );
  }

  /// Creates a model from JSON response.
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "data": {
  ///     "motorcycle_id": "abc123encoded",
  ///     "profile_image_url": "https://..."
  ///   }
  /// }
  /// ```
  factory ProfileImageModel.fromJson(Map<String, dynamic> json) {
    // Handle nested 'data' object if present
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return ProfileImageModel(
      motorcycleId: data['motorcycle_id'] as String? ?? '',
      profileImageUrl: data['profile_image_url'] as String?,
    );
  }

  /// Converts the model to JSON for API requests.
  Map<String, dynamic> toJson() {
    return {'image_url': profileImageUrl};
  }

  /// Converts the model to a domain entity.
  ProfileImageEntity toEntity() {
    return ProfileImageEntity(
      motorcycleId: motorcycleId,
      profileImageUrl: profileImageUrl,
    );
  }

  @override
  ProfileImageModel copyWith({String? motorcycleId, String? profileImageUrl}) {
    return ProfileImageModel(
      motorcycleId: motorcycleId ?? this.motorcycleId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
