import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/usecases/get_service_reviews_usecase.dart';

// ─── Events ──────────────────────────────────────────────────────────

abstract class ServiceReviewsEvent {}

class FetchServiceReviews extends ServiceReviewsEvent {
  final String serviceId;
  FetchServiceReviews({required this.serviceId});
}

// ─── States ──────────────────────────────────────────────────────────

abstract class ServiceReviewsState {}

class ServiceReviewsInitial extends ServiceReviewsState {}

class ServiceReviewsLoading extends ServiceReviewsState {}

class ServiceReviewsLoaded extends ServiceReviewsState {
  final ServiceReviewSummaryEntity summary;
  ServiceReviewsLoaded({required this.summary});
}

class ServiceReviewsError extends ServiceReviewsState {
  final String message;
  ServiceReviewsError({required this.message});
}

// ─── BLoC ────────────────────────────────────────────────────────────

/// BLoC for fetching and displaying service reviews.
class ServiceReviewsBloc
    extends Bloc<ServiceReviewsEvent, ServiceReviewsState> {
  final GetServiceReviewsUseCase _getServiceReviewsUseCase;

  ServiceReviewsBloc({
    required GetServiceReviewsUseCase getServiceReviewsUseCase,
  }) : _getServiceReviewsUseCase = getServiceReviewsUseCase,
       super(ServiceReviewsInitial()) {
    on<FetchServiceReviews>(_onFetchServiceReviews);
  }

  Future<void> _onFetchServiceReviews(
    FetchServiceReviews event,
    Emitter<ServiceReviewsState> emit,
  ) async {
    emit(ServiceReviewsLoading());

    final result = await _getServiceReviewsUseCase(event.serviceId);

    result.fold(
      (error) => emit(ServiceReviewsError(message: error.message)),
      (summary) => emit(ServiceReviewsLoaded(summary: summary)),
    );
  }
}
