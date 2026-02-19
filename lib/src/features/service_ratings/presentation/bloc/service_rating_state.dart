part of 'service_rating_bloc.dart';

/// Estados del BLoC de calificación de servicios.
abstract class ServiceRatingState {}

/// Estado inicial.
class ServiceRatingInitial extends ServiceRatingState {}

/// Estado de envío en progreso.
class ServiceRatingSubmitting extends ServiceRatingState {}

/// Estado de éxito con mensaje del backend.
class ServiceRatingSuccess extends ServiceRatingState {
  final String message;

  ServiceRatingSuccess({required this.message});
}

/// Estado de error con mensaje descriptivo.
class ServiceRatingError extends ServiceRatingState {
  final String message;

  ServiceRatingError({required this.message});
}
