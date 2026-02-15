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
  final BranchCatalogs catalogs;

  // Location fields (from locations table)
  final BranchLocation location;

  const BranchEntity({
    this.id,
    required this.name,
    required this.establishmentType,
    this.franchiseId,
    this.profileImageUrl,
    this.status = BranchStatus.active,
    this.catalogs = const BranchCatalogs(),
    required this.location,
  });

  // Convenience accessors for catalog fields.
  List<String> get brands => catalogs.brands;
  List<String> get displacementRanges => catalogs.displacementRanges;

  // Convenience accessors for location fields.
  String get address => location.address;
  String get cityId => location.cityId;
  String? get cityName => location.cityName;
  String get departmentId => location.departmentId;
  String? get departmentName => location.departmentName;

  /// Creates a copy of this entity with the given fields replaced.
  BranchEntity copyWith({
    String? name,
    String? establishmentType,
    String? franchiseId,
    String? profileImageUrl,
    String? status,
    BranchCatalogs? catalogs,
    BranchLocation? location,
  }) {
    return BranchEntity(
      id: id,
      name: name ?? this.name,
      establishmentType: establishmentType ?? this.establishmentType,
      franchiseId: franchiseId ?? this.franchiseId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
      catalogs: catalogs ?? this.catalogs,
      location: location ?? this.location,
    );
  }
}

/// Value object grouping the catalog selections for a branch.
class BranchCatalogs {
  final List<String> brands;
  final List<String> displacementRanges;

  const BranchCatalogs({
    this.brands = const [],
    this.displacementRanges = const [],
  });
}

/// Value object representing the physical location of a branch.
class BranchLocation {
  final String address;
  final String cityId;
  final String? cityName;
  final String departmentId;
  final String? departmentName;

  const BranchLocation({
    required this.address,
    required this.cityId,
    this.cityName,
    required this.departmentId,
    this.departmentName,
  });

  /// Creates a copy with updated values.
  BranchLocation copyWith({
    String? address,
    String? cityId,
    String? cityName,
    String? departmentId,
    String? departmentName,
  }) {
    return BranchLocation(
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
