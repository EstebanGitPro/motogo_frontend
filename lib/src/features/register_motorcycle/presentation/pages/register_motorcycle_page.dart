import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/core/widgets/image_picker_widget.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/entities/motorcycle_reference_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/presentation/widgets/motorcycle_reference_selector.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_event.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_state.dart';
import 'package:uuid/uuid.dart';

/// Page for registering a new motorcycle.
///
/// Provides a form with:
/// - License plate (required)
/// - Motorcycle reference (searchable dropdown)
/// - Year (optional)
/// - Current mileage (optional)
/// - Owner notes (optional)
class RegisterMotorcyclePage extends StatefulWidget {
  const RegisterMotorcyclePage({super.key});

  @override
  State<RegisterMotorcyclePage> createState() => _RegisterMotorcyclePageState();
}

class _RegisterMotorcyclePageState extends State<RegisterMotorcyclePage> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _notesController = TextEditingController();

  MotorcycleReferenceEntity? _selectedReference;

  // Image state
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _licensePlateController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectorApp.resolve<RegisterMotorcycleBloc>(),
      child: BlocConsumer<RegisterMotorcycleBloc, RegisterMotorcycleState>(
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state is RegisterMotorcycleSuccess) {
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is RegisterMotorcycleFailure) {
            messenger.clearSnackBars();
            messenger.showSnackBar(
              SnackBar(
                content: Text(state.error.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(MotorcycleConstants.registerMotorcycleTitle),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 1,
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[50]!, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Builder(
                    builder: (context) {
                      final isLoading =
                          state is RegisterMotorcycleLoading ||
                          _isUploadingImage;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 16),
                              _buildImageSection(isLoading),
                              const SizedBox(height: 24),
                              _buildLicensePlateField(),
                              const SizedBox(height: 16),
                              MotorcycleReferenceSelector(
                                onReferenceSelected: (reference) {
                                  setState(() {
                                    _selectedReference = reference;
                                  });
                                },
                                initialReference: _selectedReference,
                              ),
                              const SizedBox(height: 16),
                              _buildYearField(),
                              const SizedBox(height: 16),
                              _buildMileageField(),
                              const SizedBox(height: 16),
                              _buildNotesField(),
                              const SizedBox(height: 32),
                              _buildSubmitButton(context, state),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.two_wheeler, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MotorcycleConstants.basicInfoTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  MotorcycleConstants.basicInfoSubtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(bool isLoading) {
    return ImagePickerWidget(
      selectedImage: _selectedImage,
      onImageChanged: (file) {
        setState(() {
          _selectedImage = file;
          _uploadedImageUrl = null; // Reset if changed
        });
      },
      enabled: !isLoading,
      isUploading: _isUploadingImage,
      label: MotorcycleConstants.profileImageLabel,
      hint: MotorcycleConstants.profileImageHint,
    );
  }

  // Removed - now using ImagePickerWidget

  Widget _buildLicensePlateField() {
    return TextFormField(
      controller: _licensePlateController,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: MotorcycleConstants.licensePlateLabel,
        hintText: MotorcycleConstants.licensePlateHint,
        prefixIcon: const Icon(Icons.confirmation_number_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
        LengthLimitingTextInputFormatter(7), // Allow for space in car plates
        UpperCaseTextFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return MotorcycleConstants.licensePlateRequired;
        }
        // Remove spaces for validation
        final cleanValue = value.replaceAll(' ', '');
        // Colombian plate formats:
        // - Motorcycle: 3 letters + 2 numbers + 1 letter (e.g., MRC35E)
        // - Car: 3 letters + 3 numbers (e.g., XYZ123)
        final motorcyclePlateRegex = RegExp(r'^[A-Z]{3}[0-9]{2}[A-Z]$');
        final carPlateRegex = RegExp(r'^[A-Z]{3}[0-9]{3}$');
        if (!motorcyclePlateRegex.hasMatch(cleanValue) &&
            !carPlateRegex.hasMatch(cleanValue)) {
          return MotorcycleConstants.licensePlateInvalid;
        }
        return null;
      },
    );
  }

  Widget _buildYearField() {
    final currentYear = DateTime.now().year;
    return TextFormField(
      controller: _yearController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: MotorcycleConstants.yearLabel,
        hintText: MotorcycleConstants.yearHint,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null; // Optional field
        }
        final year = int.tryParse(value);
        if (year == null || year < 1950 || year > currentYear + 1) {
          return MotorcycleConstants.invalidYearRange(currentYear + 1);
        }
        return null;
      },
    );
  }

  Widget _buildMileageField() {
    return TextFormField(
      controller: _mileageController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: MotorcycleConstants.currentMileageLabel,
        hintText: MotorcycleConstants.currentMileageHint,
        prefixIcon: const Icon(Icons.speed_outlined),
        suffixText: 'km',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null; // Optional field
        }
        final mileage = int.tryParse(value);
        if (mileage == null || mileage < 0) {
          return MotorcycleConstants.invalidMileage;
        }
        return null;
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: MotorcycleConstants.ownerNotesLabel,
        hintText: MotorcycleConstants.ownerNotesHint,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 48),
          child: Icon(Icons.notes_outlined),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    RegisterMotorcycleState state,
  ) {
    final isLoading = state is RegisterMotorcycleLoading;

    return ElevatedButton(
      onPressed: isLoading ? null : () => _submitForm(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: Colors.blue[300],
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              MotorcycleConstants.registerButton,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // Capture bloc reference before async
      final bloc = context.read<RegisterMotorcycleBloc>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      String? profileImageUrl = _uploadedImageUrl;

      // Upload image if selected and not already uploaded
      if (_selectedImage != null && _uploadedImageUrl == null) {
        setState(() => _isUploadingImage = true);

        final storageService = InjectorApp.resolve<StorageService>();

        // Generate a temporary ID for the upload path
        final tempMotorcycleId = const Uuid().v4();

        final uploadResult = await storageService.uploadMotorcycleImage(
          motorcycleId: tempMotorcycleId,
          file: _selectedImage!,
        );

        if (!mounted) return;

        setState(() => _isUploadingImage = false);

        if (uploadResult.isLeft) {
          scaffoldMessenger.clearSnackBars();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                '${MotorcycleConstants.profileImageUploadError}: ${uploadResult.left.message}',
              ),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: MotorcycleConstants.retryButton,
                textColor: Colors.white,
                onPressed: () => _submitForm(context),
              ),
            ),
          );
          return; // This return now properly exits _submitForm()
        }

        // Upload succeeded - get the URL
        profileImageUrl = uploadResult.right;
        _uploadedImageUrl = profileImageUrl;
      }

      if (!mounted) return;

      bloc.add(
        SubmitMotorcycleRegistration(
          licensePlate: _licensePlateController.text.trim().replaceAll(' ', ''),
          referenceId: _selectedReference?.id,
          year: _yearController.text.isNotEmpty
              ? int.parse(_yearController.text)
              : null,
          currentMileage: _mileageController.text.isNotEmpty
              ? int.parse(_mileageController.text)
              : null,
          ownerNotes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          profileImageUrl: profileImageUrl,
        ),
      );
    }
  }
}

/// Text formatter to convert input to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
