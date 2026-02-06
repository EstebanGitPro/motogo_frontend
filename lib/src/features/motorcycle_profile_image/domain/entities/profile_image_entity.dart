import 'package:equatable/equatable.dart';

/// Entity representing the profile image of a motorcycle.
///
/// Part of the domain layer for the motorcycle_profile_image feature.
class ProfileImageEntity extends Equatable {
  final String motorcycleId;
  final String? profileImageUrl;

  const ProfileImageEntity({required this.motorcycleId, this.profileImageUrl});

  @override
  List<Object?> get props => [motorcycleId, profileImageUrl];

  /// Creates a copy with optional overrides.
  ProfileImageEntity copyWith({String? motorcycleId, String? profileImageUrl}) {
    return ProfileImageEntity(
      motorcycleId: motorcycleId ?? this.motorcycleId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
