import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/core/widgets/image_picker_widget.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/domain/usecases/update_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/presentation/bloc/edit_motorcycle_bloc.dart';
import 'package:motogo_frontend/src/features/motorcycle_profile_image/domain/usecases/delete_profile_image_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';
import 'package:uuid/uuid.dart';

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

  // Image state
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

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
    // Initialize with existing image URL if available
    _uploadedImageUrl = widget.motorcycle.profileImageUrl;
  }

  @override
  void dispose() {
    _plateController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Delete existing profile image using dedicated endpoint
  Future<void> _onDeleteExistingImage() async {
    final motorcycleId = widget.motorcycle.id;
    if (motorcycleId == null) return;

    setState(() => _isUploadingImage = true);

    final deleteUseCase = InjectorApp.resolve<DeleteProfileImageUseCase>();
    final result = await deleteUseCase.call(motorcycleId: motorcycleId);

    if (!mounted) return;

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      },
      (message) {
        setState(() {
          _uploadedImageUrl = null;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      },
    );

    setState(() => _isUploadingImage = false);
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
          title: const Text(MotorcycleConstants.editMotorcycleTitle),
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
                // Image picker section
                ImagePickerWidget(
                  selectedImage: _selectedImage,
                  existingImageUrl: _uploadedImageUrl,
                  onImageChanged: (file) {
                    setState(() {
                      _selectedImage = file;
                      // Don't reset _uploadedImageUrl - keep it for fallback
                    });
                  },
                  onExistingImageRemoved: _onDeleteExistingImage,
                  enabled: true,
                  isUploading: _isUploadingImage,
                  label: MotorcycleConstants.profileImageLabel,
                  hint: MotorcycleConstants.profileImageHint,
                ),
                const SizedBox(height: 16),
                // Plate field (read-only)
                TextFormField(
                  controller: _plateController,
                  enabled: false, // Plate cannot be changed
                  decoration: InputDecoration(
                    labelText: MotorcycleConstants.licensePlateLabel,
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
                  MotorcycleConstants.plateReadonlyMessage,
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
                    labelText: MotorcycleConstants.yearOptionalLabel,
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final year = int.tryParse(value);
                      if (year == null || year < 1900 || year > 2030) {
                        return MotorcycleConstants.invalidYear;
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
                    labelText: MotorcycleConstants.mileageOptionalLabel,
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
                        return MotorcycleConstants.invalidMileage;
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
                    labelText: MotorcycleConstants.notesOptionalLabel,
                    hintText: MotorcycleConstants.notesOptionalHint,
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
                              MotorcycleConstants.saveChangesButton,
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

  Future<void> _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Capture bloc reference before async
      final bloc = context.read<EditMotorcycleBloc>();
      String? profileImageUrl = _uploadedImageUrl;

      // Upload image if a new one was selected
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);

        final storageService = InjectorApp.resolve<StorageService>();

        // Use existing motorcycle ID or generate temp one
        final motorcycleId = widget.motorcycle.id ?? const Uuid().v4();

        final uploadResult = await storageService.uploadMotorcycleImage(
          motorcycleId: motorcycleId,
          file: _selectedImage!,
        );

        if (!mounted) return;

        setState(() => _isUploadingImage = false);

        if (uploadResult.isLeft) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${MotorcycleConstants.profileImageUploadError}: ${uploadResult.left.message}',
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: MotorcycleConstants.retryButton,
                textColor: Colors.white,
                onPressed: _onSave,
              ),
            ),
          );
          return; // This return now properly exits _onSave()
        }

        // Upload succeeded - get the URL
        profileImageUrl = uploadResult.right;
        _uploadedImageUrl = profileImageUrl;
      }

      if (!mounted) return;

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
        profileImageUrl: profileImageUrl,
      );

      bloc.add(
        UpdateMotorcycle(
          id: widget.motorcycle.id!,
          motorcycle: updatedMotorcycle,
        ),
      );
    }
  }
}
