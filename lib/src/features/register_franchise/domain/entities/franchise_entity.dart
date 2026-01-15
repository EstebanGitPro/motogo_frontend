import 'package:equatable/equatable.dart';

/// Entity representing a franchise in the MotoGo system.
///
/// A franchise is a grouping of branches (sedes) under a common brand.
/// A franchise must have at least one branch to be valid.
class FranchiseEntity extends Equatable {
  final String? id;
  final String name;
  final String? description;
  final List<String> branchIds;

  const FranchiseEntity({
    this.id,
    required this.name,
    this.description,
    this.branchIds = const [],
  });

  FranchiseEntity copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? branchIds,
  }) {
    return FranchiseEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      branchIds: branchIds ?? this.branchIds,
    );
  }

  @override
  List<Object?> get props => [id, name, description, branchIds];
}
