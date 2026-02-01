import 'package:equatable/equatable.dart';

/// Events for the RegisterMotorcycle BLoC.
sealed class RegisterMotorcycleEvent extends Equatable {
  const RegisterMotorcycleEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit the motorcycle registration form.
class SubmitMotorcycleRegistration extends RegisterMotorcycleEvent {
  final String licensePlate;
  final String? referenceId;
  final int? year;
  final int? currentMileage;
  final String? ownerNotes;

  const SubmitMotorcycleRegistration({
    required this.licensePlate,
    this.referenceId,
    this.year,
    this.currentMileage,
    this.ownerNotes,
  });

  @override
  List<Object?> get props => [
    licensePlate,
    referenceId,
    year,
    currentMileage,
    ownerNotes,
  ];
}

/// Event to reset the form to initial state.
class ResetMotorcycleForm extends RegisterMotorcycleEvent {
  const ResetMotorcycleForm();
}
