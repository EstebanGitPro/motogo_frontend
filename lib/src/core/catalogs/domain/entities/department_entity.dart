/// Domain entity for a Colombian department.
class DepartmentEntity {
  final String id;
  final String name;

  const DepartmentEntity({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'DepartmentEntity(id: $id, name: $name)';
}
