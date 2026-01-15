import 'package:equatable/equatable.dart';

/// Base class for manage franchise events.
abstract class ManageFranchiseEvent extends Equatable {
  const ManageFranchiseEvent();

  @override
  List<Object?> get props => [];
}

/// Load franchise details with its branches.
class LoadFranchise extends ManageFranchiseEvent {
  final String franchiseId;

  const LoadFranchise(this.franchiseId);

  @override
  List<Object?> get props => [franchiseId];
}

/// Unlink a branch from the franchise.
class UnlinkBranchEvent extends ManageFranchiseEvent {
  final String branchId;

  const UnlinkBranchEvent(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Link a branch to the franchise.
class LinkBranchEvent extends ManageFranchiseEvent {
  final String branchId;

  const LinkBranchEvent(this.branchId);

  @override
  List<Object?> get props => [branchId];
}

/// Update franchise info.
class UpdateFranchiseEvent extends ManageFranchiseEvent {
  final String name;
  final String? description;

  const UpdateFranchiseEvent({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

/// Delete the franchise.
class DeleteFranchiseEvent extends ManageFranchiseEvent {
  const DeleteFranchiseEvent();
}
