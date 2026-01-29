import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/domain/usecases/update_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/presentation/bloc/edit_motorcycle_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Page for editing an existing motorcycle.
class EditMotorcyclePage extends StatelessWidget {
  final MotorcycleEntity motorcycle;

  const EditMotorcyclePage({super.key, required this.motorcycle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditMotorcycleBloc(
        updateMotorcycleUseCase: InjectorApp.resolve<UpdateMotorcycleUseCase>(),
      ),
      child: _EditMotorcycleView(motorcycle: motorcycle),
    );
  }
}

class _EditMotorcycleView extends StatefulWidget {
  final MotorcycleEntity motorcycle;

  const _EditMotorcycleView({required this.motorcycle});

  @override
  State<_EditMotorcycleView> createState() => _EditMotorcycleViewState();
}

class _EditMotorcycleViewState extends State<_EditMotorcycleView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _yearController;
  late final TextEditingController _mileageController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(
      text: widget.motorcycle.licensePlate,
    );
    _yearController = TextEditingController(
      text: widget.motorcycle.year?.toString() ?? '',
    );
    _mileageController = TextEditingController(
      text: widget.motorcycle.currentMileage?.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.motorcycle.ownerNotes ?? '',
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditMotorcycleBloc, EditMotorcycleState>(
      listener: (context, state) {
        if (state is EditMotorcycleSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to refresh list
        }
        if (state is EditMotorcycleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Editar Moto'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Plate field (read-only)
                TextFormField(
                  controller: _plateController,
                  enabled: false, // Plate cannot be changed
                  decoration: InputDecoration(
                    labelText: 'Placa',
                    prefixIcon: const Icon(Icons.badge),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La placa no se puede modificar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),

                // Year field
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Año (opcional)',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final year = int.tryParse(value);
                      if (year == null || year < 1900 || year > 2030) {
                        return 'Ingresa un año válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Mileage field
                TextFormField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kilometraje actual (opcional)',
                    prefixIcon: const Icon(Icons.speed),
                    suffixText: 'km',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final mileage = int.tryParse(value);
                      if (mileage == null || mileage < 0) {
                        return 'Ingresa un kilometraje válido';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Notes field
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: 'Notas (opcional)',
                    hintText: 'Ej: Mi moto del trabajo',
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                BlocBuilder<EditMotorcycleBloc, EditMotorcycleState>(
                  builder: (context, state) {
                    final isLoading = state is EditMotorcycleSaving;

                    return ElevatedButton(
                      onPressed: isLoading ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedMotorcycle = MotorcycleEntity(
        id: widget.motorcycle.id,
        licensePlate: _plateController.text.trim(),
        year: _yearController.text.isNotEmpty
            ? int.tryParse(_yearController.text)
            : null,
        currentMileage: _mileageController.text.isNotEmpty
            ? int.tryParse(_mileageController.text)
            : null,
        ownerNotes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      context.read<EditMotorcycleBloc>().add(
        UpdateMotorcycle(
          id: widget.motorcycle.id!,
          motorcycle: updatedMotorcycle,
        ),
      );
    }
  }
}
