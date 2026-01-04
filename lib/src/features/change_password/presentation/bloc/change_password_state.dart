part of 'change_password_bloc.dart';

/// Estados del BLoC de cambio de contraseña.
abstract class ChangePasswordState {}

/// Estado inicial.
class ChangePasswordInitial extends ChangePasswordState {}

/// Estado de carga (procesando solicitud).
class ChangePasswordLoading extends ChangePasswordState {}

/// Estado de éxito con mensaje del backend.
class ChangePasswordSuccess extends ChangePasswordState {
  final String message;

  ChangePasswordSuccess({required this.message});
}

/// Estado de error con mensaje descriptivo.
class ChangePasswordError extends ChangePasswordState {
  final String message;

  ChangePasswordError({required this.message});
}
