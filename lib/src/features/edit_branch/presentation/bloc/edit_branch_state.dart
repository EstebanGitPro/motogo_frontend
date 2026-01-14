import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// States for the EditBranchBloc.
abstract class EditBranchState {}

/// Initial state before any action.
class EditBranchInitial extends EditBranchState {}

/// State while update is in progress.
class EditBranchLoading extends EditBranchState {}

/// State when update succeeds.
class EditBranchSuccess extends EditBranchState {
  final BranchEntity updatedBranch;

  EditBranchSuccess({required this.updatedBranch});
}

/// State when update fails.
class EditBranchFailure extends EditBranchState {
  final ErrorModel error;

  EditBranchFailure({required this.error});
}
