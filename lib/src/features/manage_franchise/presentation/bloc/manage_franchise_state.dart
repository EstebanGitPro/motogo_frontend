import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

/// Base class for manage franchise states.
abstract class ManageFranchiseState extends Equatable {
  const ManageFranchiseState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state.
class ManageFranchiseLoading extends ManageFranchiseState {
  const ManageFranchiseLoading();
}

/// Franchise loaded with linked and available branches.
class ManageFranchiseLoaded extends ManageFranchiseState {
  final FranchiseEntity franchise;
  final List<BranchEntity> linkedBranches;
  final List<BranchEntity> availableBranches;

  const ManageFranchiseLoaded({
    required this.franchise,
    required this.linkedBranches,
    required this.availableBranches,
  });

  @override
  List<Object?> get props => [franchise, linkedBranches, availableBranches];
}

/// Error loading or performing action.
class ManageFranchiseError extends ManageFranchiseState {
  final String message;

  const ManageFranchiseError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Franchise deleted successfully.
class ManageFranchiseDeleted extends ManageFranchiseState {
  final String message;

  const ManageFranchiseDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Franchise updated successfully.
class ManageFranchiseUpdated extends ManageFranchiseState {
  final FranchiseEntity franchise;
  final String message;

  const ManageFranchiseUpdated({
    required this.franchise,
    required this.message,
  });

  @override
  List<Object?> get props => [franchise, message];
}
