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
  final double? userLatitude;
  final double? userLongitude;
  final List<BranchMarkerEntity> branches;
  final String? selectedBranchId;
  final String? activeTypeFilter;
  final String? activeBrandFilter;
  final String? activeDisplacementRangeFilter;
  final bool locationPermissionDenied;
  final double currentRadiusKm;
  final bool isLoadingBranches;
  final String? errorMessage; // Error message to show in snackbar

  const UserHomeLoaded({
    this.userLatitude,
    this.userLongitude,
    this.branches = const [],
    this.selectedBranchId,
    this.activeTypeFilter,
    this.activeBrandFilter,
    this.activeDisplacementRangeFilter,
    this.locationPermissionDenied = false,
    this.currentRadiusKm = 5.0,
    this.isLoadingBranches = false,
    this.errorMessage,
  });

  /// Creates a copy with updated values.
  ///
  /// Use [clear] to reset nullable fields to `null`. Example:
  /// ```dart
  /// state.copyWith(clear: ClearFlags(selectedBranch: true));
  /// ```
  UserHomeLoaded copyWith({
    double? userLatitude,
    double? userLongitude,
    List<BranchMarkerEntity>? branches,
    String? selectedBranchId,
    String? activeTypeFilter,
    String? activeBrandFilter,
    String? activeDisplacementRangeFilter,
    bool? locationPermissionDenied,
    double? currentRadiusKm,
    bool? isLoadingBranches,
    String? errorMessage,
    ClearFlags clear = const ClearFlags(),
  }) {
    return UserHomeLoaded(
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      branches: branches ?? this.branches,
      selectedBranchId: clear.selectedBranch
          ? null
          : (selectedBranchId ?? this.selectedBranchId),
      activeTypeFilter: clear.activeTypeFilter
          ? null
          : (activeTypeFilter ?? this.activeTypeFilter),
      activeBrandFilter: clear.activeBrandFilter
          ? null
          : (activeBrandFilter ?? this.activeBrandFilter),
      activeDisplacementRangeFilter: clear.activeDisplacementRangeFilter
          ? null
          : (activeDisplacementRangeFilter ??
                this.activeDisplacementRangeFilter),
      locationPermissionDenied:
          locationPermissionDenied ?? this.locationPermissionDenied,
      currentRadiusKm: currentRadiusKm ?? this.currentRadiusKm,
      isLoadingBranches: isLoadingBranches ?? this.isLoadingBranches,
      errorMessage: clear.error ? null : (errorMessage ?? this.errorMessage),
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
    userLatitude,
    userLongitude,
    branches,
    selectedBranchId,
    activeTypeFilter,
    activeBrandFilter,
    activeDisplacementRangeFilter,
    locationPermissionDenied,
    currentRadiusKm,
    isLoadingBranches,
    errorMessage,
  ];
}

/// State when an error occurs.
class UserHomeError extends UserHomeState {
  final String message;

  const UserHomeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Groups the clear-flag booleans used by [UserHomeLoaded.copyWith]
/// to reset nullable fields to `null`.
class ClearFlags {
  final bool selectedBranch;
  final bool activeTypeFilter;
  final bool activeBrandFilter;
  final bool activeDisplacementRangeFilter;
  final bool error;

  const ClearFlags({
    this.selectedBranch = false,
    this.activeTypeFilter = false,
    this.activeBrandFilter = false,
    this.activeDisplacementRangeFilter = false,
    this.error = false,
  });
}
