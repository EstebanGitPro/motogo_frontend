part of 'change_password_bloc.dart';

/// Eventos del BLoC de cambio de contraseña.
abstract class ChangePasswordEvent {}

/// Evento para solicitar el cambio de contraseña.
class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
  });
}
