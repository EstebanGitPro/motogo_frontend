import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_reference_entity.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/usecases/get_motorcycle_references_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_event.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/bloc/register_motorcycle_state.dart';

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
  final _searchController = TextEditingController();

  List<MotorcycleReferenceEntity> _allReferences = [];
  List<MotorcycleReferenceEntity> _filteredReferences = [];
  MotorcycleReferenceEntity? _selectedReference;
  bool _isLoadingReferences = true;
  String? _referencesError;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadReferences();
    _searchController.addListener(_filterReferences);
  }

  Future<void> _loadReferences() async {
    final useCase = InjectorApp.resolve<GetMotorcycleReferencesUseCase>();
    final result = await useCase();

    if (mounted) {
      setState(() {
        result.fold(
          (error) {
            _referencesError = error.message;
            _isLoadingReferences = false;
          },
          (references) {
            _allReferences = references;
            _filteredReferences = references;
            _isLoadingReferences = false;
          },
        );
      });
    }
  }

  void _filterReferences() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReferences = _allReferences;
      } else {
        _filteredReferences = _allReferences.where((ref) {
          return ref.displayName.toLowerCase().contains(query) ||
              ref.brandName.toLowerCase().contains(query) ||
              ref.model.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterMotorcycleBloc(),
      child: BlocConsumer<RegisterMotorcycleBloc, RegisterMotorcycleState>(
        listener: (context, state) {
          if (state is RegisterMotorcycleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is RegisterMotorcycleFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
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
              onTap: () {
                FocusScope.of(context).unfocus();
                setState(() => _showDropdown = false);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[50]!, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildLicensePlateField(),
                          const SizedBox(height: 16),
                          _buildReferenceSelector(),
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
                  'Información Básica',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Registra los datos de tu motocicleta',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildReferenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected reference or search field
        GestureDetector(
          onTap: () {
            setState(() => _showDropdown = !_showDropdown);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Row(
              children: [
                Icon(Icons.motorcycle_outlined, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectedReference != null
                      ? Text(
                          _selectedReference!.displayName,
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          'Seleccionar referencia (opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                if (_selectedReference != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedReference = null;
                        _searchController.clear();
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  Icon(
                    _showDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.grey[600],
                  ),
              ],
            ),
          ),
        ),

        // Dropdown content
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar marca o modelo...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                  ),
                ),

                // References list
                if (_isLoadingReferences)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_referencesError != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _referencesError!,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: _filteredReferences.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No se encontraron referencias'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredReferences.length,
                            itemBuilder: (context, index) {
                              final ref = _filteredReferences[index];
                              final isSelected =
                                  _selectedReference?.id == ref.id;
                              return ListTile(
                                title: Text(
                                  '${ref.brandName} ${ref.model}',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '${ref.category ?? ''} - ${ref.engineDisplacementCc ?? 0}cc',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                selected: isSelected,
                                selectedTileColor: Colors.blue[50],
                                onTap: () {
                                  setState(() {
                                    _selectedReference = ref;
                                    _showDropdown = false;
                                    _searchController.clear();
                                  });
                                },
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
      ],
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
          return 'Año inválido (1950-${currentYear + 1})';
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
          return 'Kilometraje inválido';
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

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<RegisterMotorcycleBloc>().add(
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
