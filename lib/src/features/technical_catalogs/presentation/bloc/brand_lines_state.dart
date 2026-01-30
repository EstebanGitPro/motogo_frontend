part of 'brand_lines_bloc.dart';

/// States for the BrandLinesBloc.
abstract class BrandLinesState extends Equatable {
  const BrandLinesState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class BrandLinesInitial extends BrandLinesState {
  const BrandLinesInitial();
}

/// Loading brands list.
class BrandLinesLoadingBrands extends BrandLinesState {
  const BrandLinesLoadingBrands();
}

/// Brands loaded successfully.
class BrandLinesLoadedBrands extends BrandLinesState {
  final List<BrandEntity> brands;

  const BrandLinesLoadedBrands(this.brands);

  @override
  List<Object?> get props => [brands];
}

/// Loading lines for a brand.
class BrandLinesLoadingLines extends BrandLinesState {
  final String brandName;

  const BrandLinesLoadingLines(this.brandName);

  @override
  List<Object?> get props => [brandName];
}

/// Lines loaded successfully.
class BrandLinesLoadedLines extends BrandLinesState {
  final String brandName;
  final List<BrandLineEntity> lines;

  const BrandLinesLoadedLines({required this.brandName, required this.lines});

  @override
  List<Object?> get props => [brandName, lines];
}

/// Error state.
class BrandLinesError extends BrandLinesState {
  final String message;

  const BrandLinesError(this.message);

  @override
  List<Object?> get props => [message];
}
