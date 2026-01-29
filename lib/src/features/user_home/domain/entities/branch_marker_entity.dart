import 'package:equatable/equatable.dart';

/// Entity representing a branch marker on the map.
///
/// Contains location data and basic info for displaying on the map.
class BranchMarkerEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final double? rating;
  final String? address;
  final double? distanceKm;
  final String? typeLabel;
  final String? profileImageUrl;
  final String? cityName;
  final String? departmentName;

  const BranchMarkerEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.address,
    this.distanceKm,
    this.typeLabel,
    this.profileImageUrl,
    this.cityName,
    this.departmentName,
  });

  /// Returns true if this is a workshop.
  bool get isWorkshop => type == 'taller';

  /// Returns true if this is a store.
  bool get isStore => type == 'tienda';

  /// Returns formatted distance string.
  String get formattedDistance {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()} m';
    }
    return '${distanceKm!.toStringAsFixed(1)} km';
  }

  /// Returns the display type label.
  String get displayTypeLabel =>
      typeLabel ?? (isWorkshop ? 'Taller' : 'Tienda');

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    latitude,
    longitude,
    rating,
    address,
    distanceKm,
    typeLabel,
    profileImageUrl,
    cityName,
    departmentName,
  ];
}
