/// Entity representing a branch (sede) in the MotoGo system.
///
/// Maps to the `branches` table in the database.
class BranchEntity {
  final String? id;
  final String name;
  final String establishmentType; // WORKSHOP or STORE
  final String? franchiseId;
  final String? profileImageUrl;
  final String status; // ACTIVE or INACTIVE
  final List<String> brands; // From branch_brands table
  final List<String>
  displacementRanges; // From branch_displacement_ranges table

  // Location fields (from locations table)
  final String address;
  final String cityId;
  final String? cityName;
  final String departmentId;
  final String? departmentName;

  const BranchEntity({
    this.id,
    required this.name,
    required this.establishmentType,
    this.franchiseId,
    this.profileImageUrl,
    this.status = BranchStatus.active,
    this.brands = const [],
    this.displacementRanges = const [],
    required this.address,
    required this.cityId,
    this.cityName,
    required this.departmentId,
    this.departmentName,
  });

  /// Creates a copy of this entity with the given fields replaced.
  BranchEntity copyWith({
    String? id,
    String? name,
    String? establishmentType,
    String? franchiseId,
    String? profileImageUrl,
    String? status,
    List<String>? brands,
    List<String>? displacementRanges,
    String? address,
    String? cityId,
    String? cityName,
    String? departmentId,
    String? departmentName,
  }) {
    return BranchEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      establishmentType: establishmentType ?? this.establishmentType,
      franchiseId: franchiseId ?? this.franchiseId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      brands: brands ?? this.brands,
      displacementRanges: displacementRanges ?? this.displacementRanges,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
    );
  }
}

/// Status values for branches.
class BranchStatus {
  static const String active = 'ACTIVE';
  static const String inactive = 'INACTIVE';

  static const List<String> values = [active, inactive];
}
