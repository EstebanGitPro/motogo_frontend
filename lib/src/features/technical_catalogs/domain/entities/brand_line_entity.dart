import 'package:equatable/equatable.dart';

/// Entity representing a motorcycle line/model for a brand.
///
/// Used in HU40: Consultar Líneas de Marca.
class BrandLineEntity extends Equatable {
  final String brandName;
  final String model;

  const BrandLineEntity({required this.brandName, required this.model});

  @override
  List<Object?> get props => [brandName, model];
}
