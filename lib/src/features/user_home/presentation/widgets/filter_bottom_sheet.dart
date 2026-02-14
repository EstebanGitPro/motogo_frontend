import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';

/// Modal Bottom Sheet for filtering nearby branches by brand and displacement range.
///
/// Loads catalogs on init and allows single-selection for each filter.
/// Calls [onApply] with selected values when the user taps "Aplicar".
class FilterBottomSheet extends StatefulWidget {
  final String? currentBrand;
  final String? currentDisplacementRange;
  final void Function(String? brand, String? displacementRange) onApply;

  const FilterBottomSheet({
    super.key,
    this.currentBrand,
    this.currentDisplacementRange,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<BrandEntity> _brands = [];
  List<DisplacementRangeEntity> _displacements = [];
  bool _isLoadingBrands = true;
  bool _isLoadingDisplacements = true;

  String? _selectedBrand;
  String? _selectedDisplacement;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.currentBrand;
    _selectedDisplacement = widget.currentDisplacementRange;
    _loadCatalogs();
  }

  Future<void> _loadCatalogs() async {
    final catalogsRepo = InjectorApp.resolve<CatalogsRepository>();

    final brandsResult = await catalogsRepo.getBrands();
    if (mounted) {
      setState(() {
        brandsResult.fold((_) => _brands = [], (brands) => _brands = brands);
        _isLoadingBrands = false;
      });
    }

    final displacementsResult = await catalogsRepo.getDisplacementRanges();
    if (mounted) {
      setState(() {
        displacementsResult.fold(
          (_) => _displacements = [],
          (displacements) => _displacements = displacements,
        );
        _isLoadingDisplacements = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters =
        _selectedBrand != null || _selectedDisplacement != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                MotorcycleConstants.filterTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Brand section
          Text(
            MotorcycleConstants.filterBrandSection,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _isLoadingBrands
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _brands.map((brand) {
                    final isSelected = _selectedBrand == brand.id;
                    return FilterChip(
                      label: Text(brand.name),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedBrand = isSelected ? null : brand.id;
                        });
                      },
                      selectedColor: Colors.blue[600],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
          const SizedBox(height: 20),

          // Displacement range section
          Text(
            MotorcycleConstants.filterDisplacementSection,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _isLoadingDisplacements
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _displacements.map((d) {
                    final isSelected = _selectedDisplacement == d.range;
                    return FilterChip(
                      label: Text(d.displayLabel),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedDisplacement = isSelected ? null : d.range;
                        });
                      },
                      selectedColor: Colors.green[600],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: hasActiveFilters
                      ? () {
                          setState(() {
                            _selectedBrand = null;
                            _selectedDisplacement = null;
                          });
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(MotorcycleConstants.filterClear),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedBrand, _selectedDisplacement);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(MotorcycleConstants.filterApply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
