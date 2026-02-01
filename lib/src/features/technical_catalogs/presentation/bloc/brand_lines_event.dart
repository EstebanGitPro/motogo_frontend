part of 'brand_lines_bloc.dart';

/// Events for the BrandLinesBloc.
abstract class BrandLinesEvent extends Equatable {
  const BrandLinesEvent();

  @override
  List<Object?> get props => [];
}

/// Load brands for selection.
class LoadBrands extends BrandLinesEvent {
  const LoadBrands();
}

/// Load lines for a specific brand.
class LoadBrandLines extends BrandLinesEvent {
  final String brandId;
  final String brandName;

  const LoadBrandLines({required this.brandId, required this.brandName});

  @override
  List<Object?> get props => [brandId, brandName];
}

/// Clear selection and go back to brand list.
class ClearBrandSelection extends BrandLinesEvent {
  const ClearBrandSelection();
}
