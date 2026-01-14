import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Events for the RegisterBranchBloc.
abstract class RegisterBranchEvent {}

/// Event triggered when the user submits the branch registration form.
class RegisterBranchSubmitted extends RegisterBranchEvent {
  final BranchEntity branch;

  RegisterBranchSubmitted({required this.branch});
}

/// Event to reset the bloc state.
class RegisterBranchReset extends RegisterBranchEvent {}
