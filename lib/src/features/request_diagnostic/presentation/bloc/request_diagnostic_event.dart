part of 'request_diagnostic_bloc.dart';

/// Events for the RequestDiagnosticBloc.
abstract class RequestDiagnosticEvent extends Equatable {
  const RequestDiagnosticEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the page with branch info and load user motorcycles.
class InitializeRequest extends RequestDiagnosticEvent {
  final String branchId;
  final String branchName;
  final String branchPhone;

  const InitializeRequest({
    required this.branchId,
    required this.branchName,
    required this.branchPhone,
  });

  @override
  List<Object?> get props => [branchId, branchName, branchPhone];
}

/// User selected a motorcycle.
class SelectMotorcycle extends RequestDiagnosticEvent {
  final MotorcycleEntity motorcycle;

  const SelectMotorcycle(this.motorcycle);

  @override
  List<Object?> get props => [motorcycle];
}

/// User updated problem description.
class UpdateProblemDescription extends RequestDiagnosticEvent {
  final String description;

  const UpdateProblemDescription(this.description);

  @override
  List<Object?> get props => [description];
}

/// User added a photo with an angle.
class AddPhoto extends RequestDiagnosticEvent {
  final String photoPath;
  final EvidenceAngle angle;

  const AddPhoto(this.photoPath, this.angle);

  @override
  List<Object?> get props => [photoPath, angle];
}

/// User removed a photo.
class RemovePhoto extends RequestDiagnosticEvent {
  final int index;

  const RemovePhoto(this.index);

  @override
  List<Object?> get props => [index];
}

/// User toggled the permission grant switch.
class TogglePermission extends RequestDiagnosticEvent {
  const TogglePermission();
}

/// User submitted the request (create diagnostic + grant permission + open WhatsApp).
class SubmitRequest extends RequestDiagnosticEvent {
  const SubmitRequest();
}

/// Load evidence for the selected motorcycle.
class LoadEvidence extends RequestDiagnosticEvent {
  final String motorcycleId;

  const LoadEvidence(this.motorcycleId);

  @override
  List<Object?> get props => [motorcycleId];
}
