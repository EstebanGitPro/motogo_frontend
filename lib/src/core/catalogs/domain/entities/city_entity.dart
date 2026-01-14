/// Domain entity for a Colombian city.
class CityEntity {
  final String id;
  final String name;

  const CityEntity({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'CityEntity(id: $id, name: $name)';
}
