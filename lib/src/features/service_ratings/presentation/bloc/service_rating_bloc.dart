import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/usecases/rate_service_item_usecase.dart';

part 'service_rating_event.dart';
part 'service_rating_state.dart';

/// BLoC para manejar la calificación de ítems de servicio.
class ServiceRatingBloc extends Bloc<ServiceRatingEvent, ServiceRatingState> {
  final RateServiceItemUseCase _rateServiceItemUseCase;

  ServiceRatingBloc({required RateServiceItemUseCase rateServiceItemUseCase})
    : _rateServiceItemUseCase = rateServiceItemUseCase,
      super(ServiceRatingInitial()) {
    on<SubmitServiceRating>(_onSubmitServiceRating);
  }

  Future<void> _onSubmitServiceRating(
    SubmitServiceRating event,
    Emitter<ServiceRatingState> emit,
  ) async {
    emit(ServiceRatingSubmitting());

    final request = RateServiceRequest(
      rating: event.rating,
      comment: event.comment,
    );

    final result = await _rateServiceItemUseCase(
      event.completedServiceId,
      event.itemId,
      request,
    );

    result.fold(
      (error) => emit(ServiceRatingError(message: error.message)),
      (message) => emit(ServiceRatingSuccess(message: message)),
    );
  }
}
