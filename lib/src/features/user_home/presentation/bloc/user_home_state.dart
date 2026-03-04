part of 'user_home_bloc.dart';

/// Base class for all UserHome states.
sealed class UserHomeState extends Equatable {
  const UserHomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class UserHomeInitial extends UserHomeState {
  const UserHomeInitial();
}

/// State when loading location or branches.
class UserHomeLoading extends UserHomeState {
  const UserHomeLoading();
}

/// State when map is ready with all data.
class UserHomeLoaded extends UserHomeState {
  final MapConfig mapConfig;
  final List<BranchMarkerEntity> branches;
  final String? selectedBranchId;
  final ActiveFilters filters;
  final BranchLoadStatus loadStatus;
  final String searchQuery;

  const UserHomeLoaded({
    this.mapConfig = const MapConfig(),
    this.branches = const [],
    this.selectedBranchId,
    this.filters = const ActiveFilters(),
    this.loadStatus = const BranchLoadStatus(),
    this.searchQuery = '',
  });

  // Convenience accessors for map config.
  double? get userLatitude => mapConfig.userLatitude;
  double? get userLongitude => mapConfig.userLongitude;
  bool get locationPermissionDenied => mapConfig.locationPermissionDenied;
  double get currentRadiusKm => mapConfig.currentRadiusKm;

  // Convenience accessors for filter fields.
  String? get activeTypeFilter => filters.type;
  String? get activeBrandFilter => filters.brand;
  String? get activeDisplacementRangeFilter => filters.displacementRange;

  // Convenience accessors for load status.
  bool get isLoadingBranches => loadStatus.isLoading;
  String? get errorMessage => loadStatus.errorMessage;

  /// Returns branches matching the current search query.
  ///
  /// Filters by name, address, type label, city, and service names
  /// (case-insensitive). Returns empty list when query is blank.
  List<BranchMarkerEntity> get searchResults {
    if (searchQuery.isEmpty) return const [];
    final q = searchQuery.toLowerCase();
    return branches
        .where(
          (b) =>
              b.name.toLowerCase().contains(q) ||
              (b.address?.toLowerCase().contains(q) ?? false) ||
              b.displayTypeLabel.toLowerCase().contains(q) ||
              (b.cityName?.toLowerCase().contains(q) ?? false) ||
              b.serviceNames.any((s) => s.toLowerCase().contains(q)),
        )
        .toList();
  }

  /// Creates a copy with updated values.
  UserHomeLoaded copyWith({
    MapConfig? mapConfig,
    List<BranchMarkerEntity>? branches,
    String? selectedBranchId,
    bool clearSelectedBranch = false,
    ActiveFilters? filters,
    BranchLoadStatus? loadStatus,
    String? searchQuery,
  }) {
    return UserHomeLoaded(
      mapConfig: mapConfig ?? this.mapConfig,
      branches: branches ?? this.branches,
      selectedBranchId: clearSelectedBranch
          ? null
          : (selectedBranchId ?? this.selectedBranchId),
      filters: filters ?? this.filters,
      loadStatus: loadStatus ?? this.loadStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Gets the selected branch entity if available.
  BranchMarkerEntity? get selectedBranch {
    if (selectedBranchId == null) return null;
    try {
      return branches.firstWhere((b) => b.id == selectedBranchId);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if user location is available.
  bool get hasUserLocation => userLatitude != null && userLongitude != null;

  @override
  List<Object?> get props => [
    mapConfig,
    branches,
    selectedBranchId,
    filters,
    loadStatus,
    searchQuery,
  ];
}

/// State when an error occurs.
class UserHomeError extends UserHomeState {
  final String message;

  const UserHomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Groups the active filter values applied to nearby branch queries.
class ActiveFilters extends Equatable {
  final String? type;
  final String? brand;
  final String? displacementRange;

  const ActiveFilters({this.type, this.brand, this.displacementRange});

  @override
  List<Object?> get props => [type, brand, displacementRange];
}

/// Groups map-related configuration: user location, radius, and permissions.
class MapConfig extends Equatable {
  final double? userLatitude;
  final double? userLongitude;
  final bool locationPermissionDenied;
  final double currentRadiusKm;

  const MapConfig({
    this.userLatitude,
    this.userLongitude,
    this.locationPermissionDenied = false,
    this.currentRadiusKm = 5.0,
  });

  /// Creates a copy with updated values.
  MapConfig copyWith({
    double? userLatitude,
    double? userLongitude,
    bool? locationPermissionDenied,
    double? currentRadiusKm,
  }) {
    return MapConfig(
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      locationPermissionDenied:
          locationPermissionDenied ?? this.locationPermissionDenied,
      currentRadiusKm: currentRadiusKm ?? this.currentRadiusKm,
    );
  }

  @override
  List<Object?> get props => [
    userLatitude,
    userLongitude,
    locationPermissionDenied,
    currentRadiusKm,
  ];
}

/// Groups loading state and error info for branch queries.
class BranchLoadStatus extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  const BranchLoadStatus({this.isLoading = false, this.errorMessage});

  @override
  List<Object?> get props => [isLoading, errorMessage];
}
