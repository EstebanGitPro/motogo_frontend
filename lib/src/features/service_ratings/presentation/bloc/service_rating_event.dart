part of 'service_rating_bloc.dart';

/// Eventos del BLoC de calificación de servicios.
abstract class ServiceRatingEvent {}

/// Evento para enviar una calificación de un ítem de servicio.
class SubmitServiceRating extends ServiceRatingEvent {
  final String completedServiceId;
  final String itemId;
  final int rating;
  final String? comment;

  SubmitServiceRating({
    required this.completedServiceId,
    required this.itemId,
    required this.rating,
    this.comment,
  });
}
