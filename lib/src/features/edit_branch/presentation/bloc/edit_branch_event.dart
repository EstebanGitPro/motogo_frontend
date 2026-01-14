import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Events for the EditBranchBloc.
abstract class EditBranchEvent {}

/// Event triggered when the user submits the branch edit form.
class EditBranchSubmitted extends EditBranchEvent {
  final String branchId;
  final BranchEntity branch;

  EditBranchSubmitted({required this.branchId, required this.branch});
}

/// Event to reset the bloc state.
class EditBranchReset extends EditBranchEvent {}
