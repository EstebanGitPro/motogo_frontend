import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/services/location_service.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/domain/usecases/get_nearby_branches_usecase.dart';

part 'user_home_event.dart';
part 'user_home_state.dart';

/// BLoC for managing UserHomePage state.
///
/// Handles user location, nearby branches loading, and marker selection.
class UserHomeBloc extends Bloc<UserHomeEvent, UserHomeState> {
  final GetNearbyBranchesUseCase _getNearbyBranchesUseCase;
  final LocationService _locationService;

  UserHomeBloc({
    required GetNearbyBranchesUseCase getNearbyBranchesUseCase,
    required LocationService locationService,
  }) : _getNearbyBranchesUseCase = getNearbyBranchesUseCase,
       _locationService = locationService,
       super(const UserHomeInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<LoadNearbyBranches>(_onLoadNearbyBranches);
    on<SelectBranch>(_onSelectBranch);
    on<ClearBranchSelection>(_onClearBranchSelection);
    on<ChangeTypeFilter>(_onChangeTypeFilter);
    on<ChangeRadius>(_onChangeRadius);
    on<ChangeBrandFilter>(_onChangeBrandFilter);
    on<ChangeDisplacementRangeFilter>(_onChangeDisplacementRangeFilter);
    on<ApplyAdvancedFilters>(_onApplyAdvancedFilters);
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<UserHomeState> emit,
  ) async {
    emit(const UserHomeLoading());

    final position = await _locationService.getCurrentPosition();

    if (position == null) {
      emit(
        const UserHomeLoaded(
          locationPermissionDenied: true,
          userLatitude: 4.60971,
          userLongitude: -74.08175,
        ),
      );

      add(
        const LoadNearbyBranches(
          latitude: 4.60971,
          longitude: -74.08175,
          radiusKm: 5.0,
        ),
      );
      return;
    }

    emit(
      UserHomeLoaded(
        userLatitude: position.latitude,
        userLongitude: position.longitude,
      ),
    );

    add(
      LoadNearbyBranches(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusKm: 5.0,
      ),
    );
  }

  void _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<UserHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is UserHomeLoaded) {
      emit(
        currentState.copyWith(
          userLatitude: event.latitude,
          userLongitude: event.longitude,
        ),
      );
    }
  }

  Future<void> _onLoadNearbyBranches(
    LoadNearbyBranches event,
    Emitter<UserHomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserHomeLoaded) return;

    emit(currentState.copyWith(isLoadingBranches: true));

    final result = await _getNearbyBranchesUseCase(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusKm: event.radiusKm,
      type: event.type,
      brand: event.brand,
      displacementRange: event.displacementRange,
    );

    result.fold(
      (error) {
        emit(
          currentState.copyWith(
            isLoadingBranches: false,
            currentRadiusKm: event.radiusKm,
            errorMessage: error.message,
          ),
        );
      },
      (branches) {
        emit(
          currentState.copyWith(
            branches: branches,
            activeTypeFilter: event.type,
            clearActiveTypeFilter: event.type == null,
            activeBrandFilter: event.brand,
            clearActiveBrandFilter: event.brand == null,
            activeDisplacementRangeFilter: event.displacementRange,
            clearActiveDisplacementRangeFilter: event.displacementRange == null,
            currentRadiusKm: event.radiusKm,
            isLoadingBranches: false,
            clearError: true,
          ),
        );
      },
    );
  }

  void _onSelectBranch(SelectBranch event, Emitter<UserHomeState> emit) {
    final currentState = state;
    if (currentState is UserHomeLoaded) {
      emit(currentState.copyWith(selectedBranchId: event.branchId));
    }
  }

  void _onClearBranchSelection(
    ClearBranchSelection event,
    Emitter<UserHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is UserHomeLoaded) {
      emit(currentState.copyWith(clearSelectedBranch: true));
    }
  }

  void _onChangeTypeFilter(
    ChangeTypeFilter event,
    Emitter<UserHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is UserHomeLoaded && currentState.hasUserLocation) {
      add(
        LoadNearbyBranches(
          latitude: currentState.userLatitude!,
          longitude: currentState.userLongitude!,
          radiusKm: currentState.currentRadiusKm,
          type: event.type,
          brand: currentState.activeBrandFilter,
          displacementRange: currentState.activeDisplacementRangeFilter,
        ),
      );
    }
  }

  void _onChangeRadius(ChangeRadius event, Emitter<UserHomeState> emit) {
    final currentState = state;
    if (currentState is UserHomeLoaded && currentState.hasUserLocation) {
      add(
        LoadNearbyBranches(
          latitude: currentState.userLatitude!,
          longitude: currentState.userLongitude!,
          radiusKm: event.radiusKm,
          type: currentState.activeTypeFilter,
          brand: currentState.activeBrandFilter,
          displacementRange: currentState.activeDisplacementRangeFilter,
        ),
      );
    }
  }

  void _onChangeBrandFilter(
    ChangeBrandFilter event,
    Emitter<UserHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is UserHomeLoaded && currentState.hasUserLocation) {
      add(
        LoadNearbyBranches(
          latitude: currentState.userLatitude!,
          longitude: currentState.userLongitude!,
          radiusKm: currentState.currentRadiusKm,
          type: currentState.activeTypeFilter,
          brand: event.brand,
          displacementRange: currentState.activeDisplacementRangeFilter,
        ),
      );
    }
  }

  void _onChangeDisplacementRangeFilter(
    ChangeDisplacementRangeFilter event,
    Emitter<UserHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is UserHomeLoaded && currentState.hasUserLocation) {
      add(
        LoadNearbyBranches(
          latitude: currentState.userLatitude!,
          longitude: currentState.userLongitude!,
          radiusKm: currentState.currentRadiusKm,
          type: currentState.activeTypeFilter,
          brand: currentState.activeBrandFilter,
          displacementRange: event.displacementRange,
        ),
      );
    }
  }

  void _onApplyAdvancedFilters(
    ApplyAdvancedFilters event,
    Emitter<UserHomeState> emit,
  ) {
    final currentState = state;
    if (currentState is UserHomeLoaded && currentState.hasUserLocation) {
      add(
        LoadNearbyBranches(
          latitude: currentState.userLatitude!,
          longitude: currentState.userLongitude!,
          radiusKm: currentState.currentRadiusKm,
          type: currentState.activeTypeFilter,
          brand: event.brand,
          displacementRange: event.displacementRange,
        ),
      );
    }
  }
}
