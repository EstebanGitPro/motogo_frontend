part of 'user_home_bloc.dart';

/// Base class for all UserHome events.
sealed class UserHomeEvent extends Equatable {
  const UserHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize the map and load user location.
class InitializeMap extends UserHomeEvent {
  const InitializeMap();
}

/// Event to update user location.
class UpdateUserLocation extends UserHomeEvent {
  final double latitude;
  final double longitude;

  const UpdateUserLocation({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

/// Event to load nearby branches.
class LoadNearbyBranches extends UserHomeEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? type;
  final String? brand;
  final String? displacementRange;

  const LoadNearbyBranches({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
    this.type,
    this.brand,
    this.displacementRange,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radiusKm,
    type,
    brand,
    displacementRange,
  ];
}

/// Event to select a branch marker.
class SelectBranch extends UserHomeEvent {
  final String branchId;

  const SelectBranch(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Event to clear branch selection.
class ClearBranchSelection extends UserHomeEvent {
  const ClearBranchSelection();
}

/// Event to change the branch type filter.
class ChangeTypeFilter extends UserHomeEvent {
  final String? type;

  const ChangeTypeFilter(this.type);

  @override
  List<Object?> get props => [type];
}

/// Event to change the search radius.
class ChangeRadius extends UserHomeEvent {
  final double radiusKm;

  const ChangeRadius(this.radiusKm);

  @override
  List<Object?> get props => [radiusKm];
}

/// Event to change the brand filter.
class ChangeBrandFilter extends UserHomeEvent {
  final String? brand;

  const ChangeBrandFilter(this.brand);

  @override
  List<Object?> get props => [brand];
}

/// Event to change the displacement range filter.
class ChangeDisplacementRangeFilter extends UserHomeEvent {
  final String? displacementRange;

  const ChangeDisplacementRangeFilter(this.displacementRange);

  @override
  List<Object?> get props => [displacementRange];
}

/// Event to apply both brand and displacement range filters at once.
/// Avoids the race condition of dispatching two separate filter events.
class ApplyAdvancedFilters extends UserHomeEvent {
  final String? brand;
  final String? displacementRange;

  const ApplyAdvancedFilters({this.brand, this.displacementRange});

  @override
  List<Object?> get props => [brand, displacementRange];
}

/// Event to search branches by name, address, or type.
class SearchBranches extends UserHomeEvent {
  final String query;

  const SearchBranches(this.query);

  @override
  List<Object?> get props => [query];
}
