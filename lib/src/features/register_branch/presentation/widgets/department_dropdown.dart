import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/widgets/dropdown_state_widgets.dart';

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
      return DropdownStateWidgets.buildLoadingState(
        icon: Icons.map_outlined,
        message: 'Cargando departamentos...',
      );
    }

    if (errorMessage != null) {
      return DropdownStateWidgets.buildErrorState(message: errorMessage!);
    }

    // Only use selected value if it exists in the list
    final effectiveValue = departments.any((d) => d.id == selectedDepartmentId)
        ? selectedDepartmentId
        : null;

    return DropdownButtonFormField<String>(
      initialValue: effectiveValue,
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
}
