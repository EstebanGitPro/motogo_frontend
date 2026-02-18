import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Bottom sheet form for registering a completed service.
///
/// The representative selects their branch, picks one or more services,
/// then enters pricing and notes. On submit, returns the form data
/// through the [onSubmit] callback.
class RegisterServiceBottomSheet extends StatefulWidget {
  final String motorcycleId;
  final void Function({
    required String branchId,
    required List<String> serviceIds,
    double? quotedPrice,
    double? finalPrice,
    String? representativeNotes,
  })
  onSubmit;

  const RegisterServiceBottomSheet({
    super.key,
    required this.motorcycleId,
    required this.onSubmit,
  });

  @override
  State<RegisterServiceBottomSheet> createState() =>
      _RegisterServiceBottomSheetState();
}

class _RegisterServiceBottomSheetState
    extends State<RegisterServiceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quotedPriceController = TextEditingController();
  final _finalPriceController = TextEditingController();
  final _notesController = TextEditingController();

  // Branch selection
  List<BranchEntity> _branches = [];
  bool _loadingBranches = true;
  String? _selectedBranchId;

  // Service selection
  List<BranchServiceEntity> _services = [];
  bool _loadingServices = false;
  final Set<String> _selectedServiceIds = {};

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    _quotedPriceController.dispose();
    _finalPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    final getBranchesUseCase = InjectorApp.resolve<GetBranchesUseCase>();
    final result = await getBranchesUseCase();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _loadingBranches = false;
        });
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(error.message), backgroundColor: Colors.red),
          );
      },
      (branches) {
        setState(() {
          _branches = branches.where((b) => b.id != null).toList();
          _loadingBranches = false;
          // If only one branch, auto-select it
          if (_branches.length == 1) {
            _selectedBranchId = _branches.first.id;
            _loadServices(_selectedBranchId!);
          }
        });
      },
    );
  }

  Future<void> _loadServices(String branchId) async {
    setState(() {
      _loadingServices = true;
      _services = [];
      _selectedServiceIds.clear();
    });

    final dataSource = InjectorApp.resolve<BranchServicesDataSource>();
    final result = await dataSource.getBranchServices(branchId);

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _loadingServices = false;
        });
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(content: Text(error.message), backgroundColor: Colors.red),
          );
      },
      (services) {
        setState(() {
          _services = services.map((m) => m.toEntity()).toList();
          _loadingServices = false;
        });
      },
    );
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(MotorcycleConstants.selectAtLeastOneService),
            backgroundColor: Colors.orange,
          ),
        );
      return;
    }

    final quotedPrice = double.tryParse(
      _quotedPriceController.text.replaceAll('.', ''),
    );
    final finalPrice = double.tryParse(
      _finalPriceController.text.replaceAll('.', ''),
    );

    widget.onSubmit(
      branchId: _selectedBranchId!,
      serviceIds: _selectedServiceIds.toList(),
      quotedPrice: quotedPrice,
      finalPrice: finalPrice,
      representativeNotes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.build_circle, color: Colors.blue[700], size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        MotorcycleConstants.registerServiceTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBranchSelector(),
                        const SizedBox(height: 20),
                        _buildServicesSelector(),
                        const SizedBox(height: 20),
                        _buildPriceFields(),
                        const SizedBox(height: 20),
                        _buildNotesField(),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchSelector() {
    if (_loadingBranches) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(MotorcycleConstants.loadingBranches),
            ],
          ),
        ),
      );
    }

    if (_branches.isEmpty) {
      return Card(
        color: Colors.orange[50],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            MotorcycleConstants.noBranchesAvailable,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedBranchId,
      decoration: InputDecoration(
        labelText: MotorcycleConstants.selectBranchLabel,
        hintText: MotorcycleConstants.selectBranchHint,
        prefixIcon: const Icon(Icons.store),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: _branches.map((branch) {
        return DropdownMenuItem<String>(
          value: branch.id,
          child: Text(branch.name),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return MotorcycleConstants.selectBranchHint;
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _selectedBranchId = value;
        });
        if (value != null) {
          _loadServices(value);
        }
      },
    );
  }

  Widget _buildServicesSelector() {
    if (_selectedBranchId == null) {
      return Card(
        color: Colors.grey[100],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Primero selecciona una sede para ver los servicios disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (_loadingServices) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text(MotorcycleConstants.loadingServices),
            ],
          ),
        ),
      );
    }

    if (_services.isEmpty) {
      return Card(
        color: Colors.orange[50],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            MotorcycleConstants.noServicesAvailable,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MotorcycleConstants.selectServicesLabel,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: Column(
            children: _services.map((service) {
              final isSelected = _selectedServiceIds.contains(service.id);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedServiceIds.add(service.id);
                    } else {
                      _selectedServiceIds.remove(service.id);
                    }
                  });
                },
                title: Text(
                  service.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: service.description.isNotEmpty
                    ? Text(
                        service.description,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      )
                    : null,
                secondary: Icon(
                  Icons.build,
                  color: isSelected ? Colors.blue : Colors.grey[400],
                ),
                activeColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedServiceIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_selectedServiceIds.length} servicio(s) seleccionado(s)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _quotedPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorFormatter(),
            ],
            decoration: InputDecoration(
              labelText: MotorcycleConstants.registerQuotedPriceLabel,
              hintText: MotorcycleConstants.registerQuotedPriceHint,
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _finalPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _ThousandsSeparatorFormatter(),
            ],
            decoration: InputDecoration(
              labelText: MotorcycleConstants.registerFinalPriceLabel,
              hintText: MotorcycleConstants.registerFinalPriceHint,
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      maxLength: 500,
      decoration: InputDecoration(
        labelText: MotorcycleConstants.registerNotesLabel,
        hintText: MotorcycleConstants.registerNotesHint,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isReady = _selectedBranchId != null && _selectedServiceIds.isNotEmpty;

    return ElevatedButton.icon(
      onPressed: isReady ? _onSubmit : null,
      icon: const Icon(Icons.check_circle),
      label: const Text(
        MotorcycleConstants.registerServiceButton,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Formatter that adds dots as thousand separators.
///
/// Example: 185000 → 185.000, 1500000 → 1.500.000
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only digits at this point (FilteringTextInputFormatter.digitsOnly runs first)
    final digits = newValue.text;
    if (digits.isEmpty) return newValue;

    // Format with dots
    final buffer = StringBuffer();
    final length = digits.length;
    for (var i = 0; i < length; i++) {
      buffer.write(digits[i]);
      final remaining = length - 1 - i;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
