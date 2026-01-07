/// Entity representing a motorcycle brand from the catalog.
///
/// Used for displaying brand options in the UI while persisting the ID.
class BrandEntity {
  final String id;
  final String name;

  const BrandEntity({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
