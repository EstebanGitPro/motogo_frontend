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

/// Success state - motorcycle found.
class SearchMotorcycleLoaded extends SearchMotorcycleState {
  final MotorcycleDetailEntity motorcycle;
  final String? solutionMessage;
  final String? solutionError;
  final bool isRegisteringService;
  final String? serviceRegistrationMessage;
  final String? serviceRegistrationError;
  final List<CompletedServiceEntity> serviceHistory;
  final bool loadingHistory;
  final String? historyError;
  final bool isUpdatingStatus;
  final String? statusUpdateMessage;
  final String? statusUpdateError;
  final List<StatusTransitionEntity> serviceTransitions;
  final bool isDeletingService;
  final String? deleteServiceMessage;
  final String? deleteServiceError;

  const SearchMotorcycleLoaded(
    this.motorcycle, {
    this.solutionMessage,
    this.solutionError,
    this.isRegisteringService = false,
    this.serviceRegistrationMessage,
    this.serviceRegistrationError,
    this.serviceHistory = const [],
    this.loadingHistory = false,
    this.historyError,
    this.isUpdatingStatus = false,
    this.statusUpdateMessage,
    this.statusUpdateError,
    this.serviceTransitions = const [],
    this.isDeletingService = false,
    this.deleteServiceMessage,
    this.deleteServiceError,
  });

  SearchMotorcycleLoaded copyWith({
    MotorcycleDetailEntity? motorcycle,
    String? solutionMessage,
    String? solutionError,
    bool? isRegisteringService,
    String? serviceRegistrationMessage,
    String? serviceRegistrationError,
    List<CompletedServiceEntity>? serviceHistory,
    bool? loadingHistory,
    String? historyError,
    bool? isUpdatingStatus,
    String? statusUpdateMessage,
    String? statusUpdateError,
    List<StatusTransitionEntity>? serviceTransitions,
    bool? isDeletingService,
    String? deleteServiceMessage,
    String? deleteServiceError,
  }) {
    return SearchMotorcycleLoaded(
      motorcycle ?? this.motorcycle,
      solutionMessage: solutionMessage,
      solutionError: solutionError,
      isRegisteringService: isRegisteringService ?? this.isRegisteringService,
      serviceRegistrationMessage: serviceRegistrationMessage,
      serviceRegistrationError: serviceRegistrationError,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      loadingHistory: loadingHistory ?? this.loadingHistory,
      historyError: historyError,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      statusUpdateMessage: statusUpdateMessage,
      statusUpdateError: statusUpdateError,
      serviceTransitions: serviceTransitions ?? this.serviceTransitions,
      isDeletingService: isDeletingService ?? this.isDeletingService,
      deleteServiceMessage: deleteServiceMessage,
      deleteServiceError: deleteServiceError,
    );
  }

  @override
  List<Object?> get props => [
    motorcycle,
    solutionMessage,
    solutionError,
    isRegisteringService,
    serviceRegistrationMessage,
    serviceRegistrationError,
    serviceHistory,
    loadingHistory,
    historyError,
    isUpdatingStatus,
    statusUpdateMessage,
    statusUpdateError,
    serviceTransitions,
    isDeletingService,
    deleteServiceMessage,
    deleteServiceError,
  ];
}

/// Error state - search failed.
class SearchMotorcycleError extends SearchMotorcycleState {
  final String message;

  const SearchMotorcycleError(this.message);

  @override
  List<Object?> get props => [message];
}
