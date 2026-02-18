import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/widgets/dropdown_state_widgets.dart';

/// Dropdown widget for selecting a city.
class CityDropdown extends StatelessWidget {
  final List<CityEntity> cities;
  final String? selectedCityId;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool isLoading;
  final String? errorMessage;
  final bool hasDepartmentSelected;

  const CityDropdown({
    super.key,
    required this.cities,
    required this.selectedCityId,
    required this.onChanged,
    this.enabled = true,
    this.isLoading = false,
    this.errorMessage,
    this.hasDepartmentSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasDepartmentSelected) {
      return DropdownStateWidgets.buildDisabledState(
        icon: Icons.location_city_outlined,
        message: 'Primero selecciona un departamento',
      );
    }

    if (isLoading) {
      return DropdownStateWidgets.buildLoadingState(
        icon: Icons.location_city_outlined,
        message: 'Cargando ciudades...',
      );
    }

    if (errorMessage != null) {
      return DropdownStateWidgets.buildErrorState(message: errorMessage!);
    }

    // Only use selected value if it exists in the list
    final effectiveValue = cities.any((c) => c.id == selectedCityId)
        ? selectedCityId
        : null;

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
      decoration: InputDecoration(
        labelText: 'Ciudad',
        hintText: 'Selecciona una ciudad',
        prefixIcon: const Icon(Icons.location_city_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      items: cities.map((city) {
        return DropdownMenuItem<String>(value: city.id, child: Text(city.name));
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona una ciudad';
        }
        return null;
      },
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }
}
