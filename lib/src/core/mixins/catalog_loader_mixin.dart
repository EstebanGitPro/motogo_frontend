import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';

/// Mixin that provides shared catalog-loading methods for branch forms.
///
/// Used by both [RegisterBranchPage] and [EditBranchPage] to eliminate
/// duplicated `_loadBrands`, `_loadDepartments`, `_loadBranchTypes`,
/// `_loadDisplacementRanges`, and `_loadCities` methods.
mixin CatalogLoaderMixin<T extends StatefulWidget> on State<T> {
  // ── Brands ──
  List<BrandEntity> availableBrands = [];
  bool isLoadingBrands = true;
  String? brandsError;

  // ── Departments ──
  List<DepartmentEntity> availableDepartments = [];
  bool isLoadingDepartments = true;
  String? departmentsError;

  // ── Cities ──
  List<CityEntity> availableCities = [];
  bool isLoadingCities = false;
  String? citiesError;

  // ── Branch types ──
  List<BranchTypeEntity> availableBranchTypes = [];
  bool isLoadingBranchTypes = true;
  String? branchTypesError;

  // ── Displacement ranges ──
  List<DisplacementRangeEntity> availableDisplacementRanges = [];
  bool isLoadingDisplacementRanges = true;
  String? displacementRangesError;

  /// Loads all catalogs in parallel.
  void loadAllCatalogs() {
    loadBrands();
    loadDepartments();
    loadBranchTypes();
    loadDisplacementRanges();
  }

  Future<void> loadBrands() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getBrands();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          isLoadingBrands = false;
          brandsError = error.message;
        });
      },
      (brands) {
        setState(() {
          isLoadingBrands = false;
          availableBrands = brands;
        });
      },
    );
  }

  Future<void> loadDepartments() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getDepartments();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          isLoadingDepartments = false;
          departmentsError = error.message;
        });
      },
      (departments) {
        setState(() {
          isLoadingDepartments = false;
          availableDepartments = departments;
        });
      },
    );
  }

  Future<void> loadBranchTypes() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getBranchTypes();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          isLoadingBranchTypes = false;
          branchTypesError = error.message;
        });
      },
      (types) {
        setState(() {
          isLoadingBranchTypes = false;
          availableBranchTypes = types;
        });
      },
    );
  }

  Future<void> loadDisplacementRanges() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getDisplacementRanges();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          isLoadingDisplacementRanges = false;
          displacementRangesError = error.message;
        });
      },
      (ranges) {
        setState(() {
          isLoadingDisplacementRanges = false;
          availableDisplacementRanges = ranges;
        });
      },
    );
  }

  Future<void> loadCities(String departmentId) async {
    setState(() {
      isLoadingCities = true;
      citiesError = null;
      availableCities = [];
    });

    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getCitiesByDepartment(departmentId);

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          isLoadingCities = false;
          citiesError = error.message;
        });
      },
      (cities) {
        setState(() {
          isLoadingCities = false;
          availableCities = cities;
        });
      },
    );
  }
}
