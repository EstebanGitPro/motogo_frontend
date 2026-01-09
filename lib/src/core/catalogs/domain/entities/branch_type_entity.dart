/// Entity representing a branch type from the catalog.
///
/// Maps to the branch-types catalog API response.
class BranchTypeEntity {
  final String code;
  final String label;

  const BranchTypeEntity({required this.code, required this.label});
}
