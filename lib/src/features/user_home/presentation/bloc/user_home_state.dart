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
    this.locationPermissionDenied = false,
    this.currentRadiusKm = 5.0,
    this.isLoadingBranches = false,
    this.errorMessage,
  });

  /// Creates a copy with updated values.
  UserHomeLoaded copyWith({
    double? userLatitude,
    double? userLongitude,
    List<BranchMarkerEntity>? branches,
    String? selectedBranchId,
    String? activeTypeFilter,
    bool? locationPermissionDenied,
    double? currentRadiusKm,
    bool? isLoadingBranches,
    String? errorMessage,
    bool clearSelectedBranch = false,
    bool clearError = false,
  }) {
    return UserHomeLoaded(
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      branches: branches ?? this.branches,
      selectedBranchId: clearSelectedBranch
          ? null
          : (selectedBranchId ?? this.selectedBranchId),
      activeTypeFilter: activeTypeFilter ?? this.activeTypeFilter,
      locationPermissionDenied:
          locationPermissionDenied ?? this.locationPermissionDenied,
      currentRadiusKm: currentRadiusKm ?? this.currentRadiusKm,
      isLoadingBranches: isLoadingBranches ?? this.isLoadingBranches,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
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
