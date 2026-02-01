import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_brand_lines_usecase.dart';

part 'brand_lines_event.dart';
part 'brand_lines_state.dart';

/// BLoC for managing brand lines catalog (HU40).
///
/// Handles loading brands list and fetching lines per brand.
class BrandLinesBloc extends Bloc<BrandLinesEvent, BrandLinesState> {
  final CatalogsRepository _catalogsRepository;
  final GetBrandLinesUseCase _getBrandLinesUseCase;

  BrandLinesBloc({
    CatalogsRepository? catalogsRepository,
    GetBrandLinesUseCase? getBrandLinesUseCase,
  }) : _catalogsRepository =
           catalogsRepository ?? InjectorApp.resolve<CatalogsRepository>(),
       _getBrandLinesUseCase =
           getBrandLinesUseCase ?? InjectorApp.resolve<GetBrandLinesUseCase>(),
       super(const BrandLinesInitial()) {
    on<LoadBrands>(_onLoadBrands);
    on<LoadBrandLines>(_onLoadBrandLines);
    on<ClearBrandSelection>(_onClearBrandSelection);
  }

  Future<void> _onLoadBrands(
    LoadBrands event,
    Emitter<BrandLinesState> emit,
  ) async {
    emit(const BrandLinesLoadingBrands());

    final result = await _catalogsRepository.getBrands();

    result.fold(
      (error) => emit(BrandLinesError(error.message)),
      (brands) => emit(BrandLinesLoadedBrands(brands)),
    );
  }

  Future<void> _onLoadBrandLines(
    LoadBrandLines event,
    Emitter<BrandLinesState> emit,
  ) async {
    emit(BrandLinesLoadingLines(event.brandName));

    final result = await _getBrandLinesUseCase(event.brandId);

    result.fold(
      (error) => emit(BrandLinesError(error.message)),
      (lines) =>
          emit(BrandLinesLoadedLines(brandName: event.brandName, lines: lines)),
    );
  }

  void _onClearBrandSelection(
    ClearBrandSelection event,
    Emitter<BrandLinesState> emit,
  ) {
    add(const LoadBrands());
  }
}
