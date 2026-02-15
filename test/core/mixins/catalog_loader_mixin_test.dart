import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/mixins/catalog_loader_mixin.dart';

// ── Mock CatalogsRepository ──

class MockCatalogsRepository implements CatalogsRepository {
  // Configurable results for each method
  Either<ErrorModel, List<BrandEntity>>? brandsResult;
  Either<ErrorModel, List<DepartmentEntity>>? departmentsResult;
  Either<ErrorModel, List<BranchTypeEntity>>? branchTypesResult;
  Either<ErrorModel, List<DisplacementRangeEntity>>? displacementRangesResult;
  Either<ErrorModel, List<CityEntity>>? citiesResult;

  @override
  Future<Either<ErrorModel, List<BrandEntity>>> getBrands() async {
    return brandsResult ?? const Right([]);
  }

  @override
  Future<Either<ErrorModel, List<DepartmentEntity>>> getDepartments() async {
    return departmentsResult ?? const Right([]);
  }

  @override
  Future<Either<ErrorModel, List<BranchTypeEntity>>> getBranchTypes() async {
    return branchTypesResult ?? const Right([]);
  }

  @override
  Future<Either<ErrorModel, List<DisplacementRangeEntity>>>
  getDisplacementRanges() async {
    return displacementRangesResult ?? const Right([]);
  }

  @override
  Future<Either<ErrorModel, List<CityEntity>>> getCitiesByDepartment(
    String departmentId,
  ) async {
    return citiesResult ?? const Right([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── Test Widget that uses the mixin ──

class _TestWidget extends StatefulWidget {
  const _TestWidget({this.onStateCreated});
  final void Function(_TestWidgetState state)? onStateCreated;

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget>
    with CatalogLoaderMixin<_TestWidget> {
  @override
  void initState() {
    super.initState();
    widget.onStateCreated?.call(this);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  late MockCatalogsRepository mockRepo;

  setUp(() {
    mockRepo = MockCatalogsRepository();
    // Register mock in the DI container
    InjectorApp.container.registerFactory<CatalogsRepository>((_) => mockRepo);
  });

  tearDown(() {
    InjectorApp.container.clear();
  });

  group('CatalogLoaderMixin', () {
    group('loadBrands', () {
      testWidgets('sets availableBrands on success', (tester) async {
        final brands = [
          const BrandEntity(id: '1', name: 'Honda'),
          const BrandEntity(id: '2', name: 'Yamaha'),
        ];
        mockRepo.brandsResult = Right(brands);

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadBrands();
        await tester.pump();

        expect(state.isLoadingBrands, isFalse);
        expect(state.availableBrands, brands);
        expect(state.brandsError, isNull);
      });

      testWidgets('sets brandsError on failure', (tester) async {
        mockRepo.brandsResult = Left(
          ErrorModel(message: 'Failed to load brands'),
        );

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadBrands();
        await tester.pump();

        expect(state.isLoadingBrands, isFalse);
        expect(state.brandsError, 'Failed to load brands');
        expect(state.availableBrands, isEmpty);
      });
    });

    group('loadDepartments', () {
      testWidgets('sets availableDepartments on success', (tester) async {
        final departments = [
          const DepartmentEntity(id: '1', name: 'Cundinamarca'),
        ];
        mockRepo.departmentsResult = Right(departments);

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadDepartments();
        await tester.pump();

        expect(state.isLoadingDepartments, isFalse);
        expect(state.availableDepartments, departments);
        expect(state.departmentsError, isNull);
      });

      testWidgets('sets departmentsError on failure', (tester) async {
        mockRepo.departmentsResult = Left(ErrorModel(message: 'Dept error'));

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadDepartments();
        await tester.pump();

        expect(state.isLoadingDepartments, isFalse);
        expect(state.departmentsError, 'Dept error');
      });
    });

    group('loadBranchTypes', () {
      testWidgets('sets availableBranchTypes on success', (tester) async {
        final types = [const BranchTypeEntity(code: 'taller', label: 'Taller')];
        mockRepo.branchTypesResult = Right(types);

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadBranchTypes();
        await tester.pump();

        expect(state.isLoadingBranchTypes, isFalse);
        expect(state.availableBranchTypes, types);
        expect(state.branchTypesError, isNull);
      });

      testWidgets('sets branchTypesError on failure', (tester) async {
        mockRepo.branchTypesResult = Left(ErrorModel(message: 'Types error'));

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadBranchTypes();
        await tester.pump();

        expect(state.isLoadingBranchTypes, isFalse);
        expect(state.branchTypesError, 'Types error');
      });
    });

    group('loadDisplacementRanges', () {
      testWidgets('sets availableDisplacementRanges on success', (
        tester,
      ) async {
        final ranges = [const DisplacementRangeEntity(range: 'BAJO')];
        mockRepo.displacementRangesResult = Right(ranges);

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadDisplacementRanges();
        await tester.pump();

        expect(state.isLoadingDisplacementRanges, isFalse);
        expect(state.availableDisplacementRanges, ranges);
        expect(state.displacementRangesError, isNull);
      });

      testWidgets('sets displacementRangesError on failure', (tester) async {
        mockRepo.displacementRangesResult = Left(
          ErrorModel(message: 'Ranges error'),
        );

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadDisplacementRanges();
        await tester.pump();

        expect(state.isLoadingDisplacementRanges, isFalse);
        expect(state.displacementRangesError, 'Ranges error');
      });
    });

    group('loadCities', () {
      testWidgets('sets availableCities on success', (tester) async {
        final cities = [const CityEntity(id: '1', name: 'Bogotá')];
        mockRepo.citiesResult = Right(cities);

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadCities('dept-1');
        await tester.pump();

        expect(state.isLoadingCities, isFalse);
        expect(state.availableCities, cities);
        expect(state.citiesError, isNull);
      });

      testWidgets('sets citiesError on failure', (tester) async {
        mockRepo.citiesResult = Left(ErrorModel(message: 'Cities error'));

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        await state.loadCities('dept-1');
        await tester.pump();

        expect(state.isLoadingCities, isFalse);
        expect(state.citiesError, 'Cities error');
      });

      testWidgets('resets state before loading', (tester) async {
        mockRepo.citiesResult = const Right([]);

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        // Simulate pre-existing state
        state.availableCities = [const CityEntity(id: '1', name: 'Old')];
        state.citiesError = 'old error';

        await state.loadCities('dept-2');
        await tester.pump();

        expect(state.isLoadingCities, isFalse);
        expect(state.availableCities, isEmpty);
        expect(state.citiesError, isNull);
      });
    });

    group('loadAllCatalogs', () {
      testWidgets('loads brands, departments, types, and ranges', (
        tester,
      ) async {
        final brands = [const BrandEntity(id: '1', name: 'Honda')];
        final departments = [
          const DepartmentEntity(id: '1', name: 'Cundinamarca'),
        ];
        final types = [const BranchTypeEntity(code: 'taller', label: 'Taller')];
        final ranges = [const DisplacementRangeEntity(range: 'BAJO')];

        mockRepo.brandsResult = Right(brands);
        mockRepo.departmentsResult = Right(departments);
        mockRepo.branchTypesResult = Right(types);
        mockRepo.displacementRangesResult = Right(ranges);

        late _TestWidgetState state;
        await tester.pumpWidget(
          MaterialApp(home: _TestWidget(onStateCreated: (s) => state = s)),
        );

        state.loadAllCatalogs();
        await tester.pumpAndSettle();

        expect(state.availableBrands, brands);
        expect(state.availableDepartments, departments);
        expect(state.availableBranchTypes, types);
        expect(state.availableDisplacementRanges, ranges);
      });
    });
  });
}
