import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

/// Base class for all register franchise events.
abstract class RegisterFranchiseEvent extends Equatable {
  const RegisterFranchiseEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit the franchise registration.
class SubmitFranchise extends RegisterFranchiseEvent {
  final FranchiseEntity franchise;

  const SubmitFranchise(this.franchise);

  @override
  List<Object?> get props => [franchise];
}

/// Event to reset the form state.
class ResetFranchiseForm extends RegisterFranchiseEvent {
  const ResetFranchiseForm();
}
