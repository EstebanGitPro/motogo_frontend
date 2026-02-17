import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';

/// Page for editing a service in the global catalog (HU68).
class EditServicePage extends StatefulWidget {
  final AdminServiceEntity service;

  const EditServicePage({super.key, required this.service});

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  late bool _isActive;
  bool _isLoading = false;
  bool _hasChanges = false;

  // Available service types (matches backend enum)
  final List<String> _serviceTypes = [
    'Mantenimiento',
    'Reparación',
    'Diagnóstico',
    'Estética',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(
      text: widget.service.description ?? '',
    );
    _selectedType = widget.service.serviceType;
    _isActive = widget.service.isActive;

    // Add listeners to track changes
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final hasChanges =
        _nameController.text != widget.service.name ||
        _descriptionController.text != (widget.service.description ?? '') ||
        _selectedType != widget.service.serviceType ||
        _isActive != widget.service.isActive;
    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminConstants.editServiceTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Service name field
                _buildTextField(
                  controller: _nameController,
                  label: AdminConstants.serviceNameLabel,
                  hint: AdminConstants.serviceNameHint,
                  icon: Icons.label,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AdminConstants.serviceNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                _buildTextField(
                  controller: _descriptionController,
                  label: AdminConstants.serviceDescriptionLabel,
                  hint: AdminConstants.serviceDescriptionHint,
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Service type dropdown
                _buildDropdownField(),
                const SizedBox(height: 16),

                // Active toggle
                _buildActiveToggle(),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _hasChanges && !_isLoading ? _onSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          AdminConstants.saveButton,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                // Cancel button
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.blue),
                  ),
                  child: const Text(
                    AdminConstants.cancelButton,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
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
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: _serviceTypes.contains(_selectedType)
          ? _selectedType
          : null,
      decoration: InputDecoration(
        labelText: AdminConstants.serviceTypeLabel,
        prefixIcon: const Icon(Icons.category, color: Colors.blue),
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
        fillColor: Colors.white,
      ),
      items: _serviceTypes
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
          _onFieldChanged();
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AdminConstants.serviceTypeRequired;
        }
        return null;
      },
    );
  }

  Widget _buildActiveToggle() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _isActive ? Icons.check_circle : Icons.cancel,
                  color: _isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AdminConstants.serviceActiveLabel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _isActive
                          ? AdminConstants.serviceAvailable
                          : AdminConstants.serviceNotAvailable,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            Switch(
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
                _onFieldChanged();
              },
              activeTrackColor: Colors.green[200],
              activeThumbColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateUseCase = InjectorApp.resolve<UpdateServiceUseCase>();
      final result = await updateUseCase(
        serviceId: widget.service.id,
        name: _nameController.text.trim(),
        serviceType: _selectedType,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        isActive: _isActive,
      );

      result.fold(
        (error) {
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(error.message),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        (updatedService) {
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(
                  content: Text(AdminConstants.serviceUpdatedSuccess),
                  backgroundColor: Colors.green,
                ),
              );
            Navigator.pop(context, true);
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
