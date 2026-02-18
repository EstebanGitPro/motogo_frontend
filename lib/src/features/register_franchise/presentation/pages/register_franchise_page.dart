import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/franchise_constants.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_event.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_state.dart';

/// Page for registering a new franchise.
///
/// Displays a form with name, description, and branch selection.
class RegisterFranchisePage extends StatefulWidget {
  /// List of available branches (without franchise) for selection.
  final List<BranchEntity> availableBranches;

  const RegisterFranchisePage({super.key, required this.availableBranches});

  @override
  State<RegisterFranchisePage> createState() => _RegisterFranchisePageState();
}

class _RegisterFranchisePageState extends State<RegisterFranchisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedBranchIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
        _selectedBranchIds.isNotEmpty;
  }

  void _toggleBranch(String branchId) {
    setState(() {
      if (_selectedBranchIds.contains(branchId)) {
        _selectedBranchIds.remove(branchId);
      } else {
        _selectedBranchIds.add(branchId);
      }
    });
  }

  void _submitFranchise() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBranchIds.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(FranchiseConstants.atLeastOneBranchRequired),
            backgroundColor: Colors.orange,
          ),
        );
      return;
    }

    final franchise = FranchiseEntity(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      branchIds: _selectedBranchIds.toList(),
    );

    context.read<RegisterFranchiseBloc>().add(SubmitFranchise(franchise));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterFranchiseBloc, RegisterFranchiseState>(
      listener: (context, state) {
        if (state is RegisterFranchiseSuccess) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          Navigator.pop(context, true);
        } else if (state is RegisterFranchiseError) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(FranchiseConstants.createFranchiseTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: widget.availableBranches.isEmpty
            ? _buildNoBranchesState()
            : _buildForm(),
      ),
    );
  }

  Widget _buildNoBranchesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              FranchiseConstants.noBranchesAvailable,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              FranchiseConstants.noBranchesAvailableHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(CommonConstants.back),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return BlocBuilder<RegisterFranchiseBloc, RegisterFranchiseState>(
      builder: (context, state) {
        final isLoading = state is RegisterFranchiseLoading;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: FranchiseConstants.franchiseNameLabel,
                          hintText: FranchiseConstants.franchiseNameHint,
                          prefixIcon: const Icon(Icons.store),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue[600]!,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return FranchiseConstants.franchiseNameRequired;
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        enabled: !isLoading,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: FranchiseConstants.descriptionLabel,
                          hintText: FranchiseConstants.descriptionHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Branch selection section
                      const Text(
                        FranchiseConstants.associateBranchesTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        FranchiseConstants.associateBranchesSubtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),

                      // Branch list
                      ...widget.availableBranches
                          .where((branch) => branch.id != null)
                          .map((branch) => _buildBranchTile(branch, isLoading)),
                    ],
                  ),
                ),
              ),
            ),

            // Submit button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: (isLoading || !_isFormValid)
                      ? null
                      : _submitFranchise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          FranchiseConstants.createFranchiseButton,
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBranchTile(BranchEntity branch, bool isLoading) {
    final branchId = branch.id!;
    final isSelected = _selectedBranchIds.contains(branchId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: isLoading ? null : () => _toggleBranch(branchId),
        leading: Checkbox(
          value: isSelected,
          onChanged: isLoading ? null : (_) => _toggleBranch(branchId),
          activeColor: Colors.blue[600],
        ),
        title: Text(
          branch.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          branch.address,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}
