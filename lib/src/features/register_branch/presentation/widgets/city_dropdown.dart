import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';

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
      return _buildDisabledState();
    }

    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
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

  Widget _buildDisabledState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.location_city_outlined, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Primero selecciona un departamento',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Row(
        children: [
          Icon(Icons.location_city_outlined, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(child: Text('Cargando ciudades...')),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}
