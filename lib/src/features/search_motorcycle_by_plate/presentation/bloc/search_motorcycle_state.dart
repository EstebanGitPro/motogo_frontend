part of 'search_motorcycle_bloc.dart';

/// States for the SearchMotorcycle BLoC.
abstract class SearchMotorcycleState extends Equatable {
  const SearchMotorcycleState();

  @override
  List<Object?> get props => [];
}

/// Initial state - search form ready.
class SearchMotorcycleInitial extends SearchMotorcycleState {
  const SearchMotorcycleInitial();
}

/// Loading state - search in progress.
class SearchMotorcycleLoading extends SearchMotorcycleState {
  const SearchMotorcycleLoading();
}

/// Groups registration-related fields.
class ServiceRegistrationStatus extends Equatable {
  final bool isRegistering;
  final String? message;
  final String? error;

  const ServiceRegistrationStatus({
    this.isRegistering = false,
    this.message,
    this.error,
  });

  ServiceRegistrationStatus copyWith({
    bool? isRegistering,
    String? message,
    String? error,
  }) {
    return ServiceRegistrationStatus(
      isRegistering: isRegistering ?? this.isRegistering,
      message: message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isRegistering, message, error];
}

/// Groups service history fields.
class ServiceHistoryStatus extends Equatable {
  final List<CompletedServiceEntity> services;
  final bool loading;
  final String? error;
  final List<StatusTransitionEntity> transitions;

  const ServiceHistoryStatus({
    this.services = const [],
    this.loading = false,
    this.error,
    this.transitions = const [],
  });

  ServiceHistoryStatus copyWith({
    List<CompletedServiceEntity>? services,
    bool? loading,
    String? error,
    List<StatusTransitionEntity>? transitions,
  }) {
    return ServiceHistoryStatus(
      services: services ?? this.services,
      loading: loading ?? this.loading,
      error: error,
      transitions: transitions ?? this.transitions,
    );
  }

  @override
  List<Object?> get props => [services, loading, error, transitions];
}

/// Groups a single async-action triplet: loading flag, success message, error.
class AsyncActionState extends Equatable {
  final bool isLoading;
  final String? message;
  final String? error;

  const AsyncActionState({this.isLoading = false, this.message, this.error});

  AsyncActionState copyWith({bool? isLoading, String? message, String? error}) {
    return AsyncActionState(
      isLoading: isLoading ?? this.isLoading,
      message: message,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, message, error];
}

/// Groups status-update, details-update, and delete action fields.
class ServiceActionStatus extends Equatable {
  final AsyncActionState statusUpdate;
  final AsyncActionState detailsUpdate;
  final AsyncActionState deleteAction;

  const ServiceActionStatus({
    this.statusUpdate = const AsyncActionState(),
    this.detailsUpdate = const AsyncActionState(),
    this.deleteAction = const AsyncActionState(),
  });

  // ─── Convenience getters (backward compatibility) ─────────────────
  bool get isUpdatingStatus => statusUpdate.isLoading;
  String? get statusUpdateMessage => statusUpdate.message;
  String? get statusUpdateError => statusUpdate.error;

  bool get isUpdatingDetails => detailsUpdate.isLoading;
  String? get detailsUpdateMessage => detailsUpdate.message;
  String? get detailsUpdateError => detailsUpdate.error;

  bool get isDeletingService => deleteAction.isLoading;
  String? get deleteServiceMessage => deleteAction.message;
  String? get deleteServiceError => deleteAction.error;

  ServiceActionStatus copyWith({
    AsyncActionState? statusUpdate,
    AsyncActionState? detailsUpdate,
    AsyncActionState? deleteAction,
  }) {
    return ServiceActionStatus(
      statusUpdate: statusUpdate ?? this.statusUpdate,
      detailsUpdate: detailsUpdate ?? this.detailsUpdate,
      deleteAction: deleteAction ?? this.deleteAction,
    );
  }

  @override
  List<Object?> get props => [statusUpdate, detailsUpdate, deleteAction];
}

/// Success state - motorcycle found.
class SearchMotorcycleLoaded extends SearchMotorcycleState {
  final MotorcycleDetailEntity motorcycle;
  final String? solutionMessage;
  final String? solutionError;
  final ServiceRegistrationStatus registration;
  final ServiceHistoryStatus history;
  final ServiceActionStatus action;

  const SearchMotorcycleLoaded(
    this.motorcycle, {
    this.solutionMessage,
    this.solutionError,
    this.registration = const ServiceRegistrationStatus(),
    this.history = const ServiceHistoryStatus(),
    this.action = const ServiceActionStatus(),
  });

  // ─── Convenience getters for backward compatibility ──────────────
  bool get isRegisteringService => registration.isRegistering;
  String? get serviceRegistrationMessage => registration.message;
  String? get serviceRegistrationError => registration.error;

  List<CompletedServiceEntity> get serviceHistory => history.services;
  bool get loadingHistory => history.loading;
  String? get historyError => history.error;
  List<StatusTransitionEntity> get serviceTransitions => history.transitions;

  bool get isUpdatingStatus => action.isUpdatingStatus;
  String? get statusUpdateMessage => action.statusUpdateMessage;
  String? get statusUpdateError => action.statusUpdateError;
  bool get isUpdatingDetails => action.isUpdatingDetails;
  String? get detailsUpdateMessage => action.detailsUpdateMessage;
  String? get detailsUpdateError => action.detailsUpdateError;
  bool get isDeletingService => action.isDeletingService;
  String? get deleteServiceMessage => action.deleteServiceMessage;
  String? get deleteServiceError => action.deleteServiceError;

  SearchMotorcycleLoaded copyWith({
    MotorcycleDetailEntity? motorcycle,
    String? solutionMessage,
    String? solutionError,
    ServiceRegistrationStatus? registration,
    ServiceHistoryStatus? history,
    ServiceActionStatus? action,
  }) {
    return SearchMotorcycleLoaded(
      motorcycle ?? this.motorcycle,
      solutionMessage: solutionMessage,
      solutionError: solutionError,
      registration: registration ?? this.registration,
      history: history ?? this.history,
      action: action ?? this.action,
    );
  }

  @override
  List<Object?> get props => [
    motorcycle,
    solutionMessage,
    solutionError,
    registration,
    history,
    action,
  ];
}

/// Error state - search failed.
class SearchMotorcycleError extends SearchMotorcycleState {
  final String message;

  const SearchMotorcycleError(this.message);

  @override
  List<Object?> get props => [message];
}
