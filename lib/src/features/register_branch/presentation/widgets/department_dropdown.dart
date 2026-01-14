import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';

/// Dropdown widget for selecting a department.
class DepartmentDropdown extends StatelessWidget {
  final List<DepartmentEntity> departments;
  final String? selectedDepartmentId;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final bool isLoading;
  final String? errorMessage;

  const DepartmentDropdown({
    super.key,
    required this.departments,
    required this.selectedDepartmentId,
    required this.onChanged,
    this.enabled = true,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    // Only use selected value if it exists in the list
    final effectiveValue = departments.any((d) => d.id == selectedDepartmentId)
        ? selectedDepartmentId
        : null;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      decoration: InputDecoration(
        labelText: 'Departamento',
        hintText: 'Selecciona un departamento',
        prefixIcon: const Icon(Icons.map_outlined),
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
      items: departments.map((dept) {
        return DropdownMenuItem<String>(value: dept.id, child: Text(dept.name));
      }).toList(),
      onChanged: enabled ? onChanged : null,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona un departamento';
        }
        return null;
      },
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
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
          Icon(Icons.map_outlined, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(child: Text('Cargando departamentos...')),
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
