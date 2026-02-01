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

  const LoadNearbyBranches({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 10.0,
    this.type,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm, type];
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
