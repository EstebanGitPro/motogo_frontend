import 'package:equatable/equatable.dart';

/// Entity representing a motorcycle reference from the catalog.
class MotorcycleReferenceEntity extends Equatable {
  final String id;
  final String brandId;
  final String brandName;
  final String model;
  final String? category;
  final int? engineDisplacementCc;

  const MotorcycleReferenceEntity({
    required this.id,
    required this.brandId,
    required this.brandName,
    required this.model,
    this.category,
    this.engineDisplacementCc,
  });

  /// Returns display name: "Brand Model (Category - CCcc)"
  String get displayName {
    final buffer = StringBuffer('$brandName $model');
    final details = <String>[];
    if (category != null) details.add(category!);
    if (engineDisplacementCc != null) details.add('${engineDisplacementCc}cc');
    if (details.isNotEmpty) {
      buffer.write(' (${details.join(' - ')})');
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
    id,
    brandId,
    brandName,
    model,
    category,
    engineDisplacementCc,
  ];
}
