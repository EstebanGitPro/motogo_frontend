import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/mixins/catalog_loader_mixin.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/core/widgets/branch_form_body.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_bloc.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_event.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:uuid/uuid.dart';

/// Page for editing an existing branch (sede).
///
/// Receives a [BranchEntity] to hydrate the form with existing data.
class EditBranchPage extends StatefulWidget {
  final BranchEntity branch;

  const EditBranchPage({super.key, required this.branch});

  @override
  State<EditBranchPage> createState() => _EditBranchPageState();
}

class _EditBranchPageState extends State<EditBranchPage>
    with CatalogLoaderMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  // Form state - initialized from existing branch
  String? _selectedEstablishmentType;
  List<String> _selectedBrandIds = [];
  List<String> _selectedDisplacementRanges = [];
  String? _selectedDepartmentId;
  String? _selectedCityId;

  // Image state
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  // BLoC instance - created once to avoid context issues
  late final EditBranchBloc _editBranchBloc;

  @override
  void initState() {
    super.initState();
    _editBranchBloc = InjectorApp.resolve<EditBranchBloc>();
    _hydrateFromBranch();
    loadAllCatalogs();
  }

  /// Pre-populate form with existing branch data
  void _hydrateFromBranch() {
    _nameController = TextEditingController(text: widget.branch.name);
    _addressController = TextEditingController(text: widget.branch.address);
    _selectedEstablishmentType = widget.branch.establishmentType;
    _selectedBrandIds = List.from(widget.branch.brands);
    _selectedDisplacementRanges = List.from(widget.branch.displacementRanges);
    _selectedDepartmentId = widget.branch.departmentId;
    _selectedCityId = widget.branch.cityId;
    _uploadedImageUrl = widget.branch.profileImageUrl;

    // Load cities for the pre-selected department (only if departmentId is not empty)
    if (_selectedDepartmentId != null && _selectedDepartmentId!.isNotEmpty) {
      loadCities(_selectedDepartmentId!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _editBranchBloc.close();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBrandIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(BranchConstants.brandRequired),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedCityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(BranchConstants.locationRequired),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String? profileImageUrl = _uploadedImageUrl;

      // Upload image if a new one was selected
      if (_selectedImage != null &&
          _uploadedImageUrl == widget.branch.profileImageUrl) {
        setState(() => _isUploadingImage = true);

        final storageService = InjectorApp.resolve<StorageService>();
        final branchId = widget.branch.id ?? const Uuid().v4();

        final uploadResult = await storageService.uploadBranchImage(
          branchId: branchId,
          file: _selectedImage!,
        );

        if (!mounted) return;

        uploadResult.fold(
          (error) {
            setState(() => _isUploadingImage = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${BranchConstants.errorUploadingImage}: ${error.message}',
                ),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: BranchConstants.retry,
                  textColor: Colors.white,
                  onPressed: _onSubmit,
                ),
              ),
            );
            return;
          },
          (url) {
            profileImageUrl = url;
            setState(() {
              _isUploadingImage = false;
              _uploadedImageUrl = url;
            });
          },
        );

        // If upload failed, don't continue
        if (profileImageUrl == widget.branch.profileImageUrl &&
            _selectedImage != null) {
          return;
        }
      }

      // Get selected city and department names for geocoding
      final selectedCity = availableCities.firstWhere(
        (c) => c.id == _selectedCityId,
        orElse: () => CityEntity(
          id: _selectedCityId!,
          name: widget.branch.cityName ?? '',
        ),
      );
      final selectedDepartment = availableDepartments.firstWhere(
        (d) => d.id == _selectedDepartmentId,
        orElse: () => DepartmentEntity(
          id: _selectedDepartmentId!,
          name: widget.branch.departmentName ?? '',
        ),
      );

      final updatedBranch = widget.branch.copyWith(
        name: _nameController.text.trim(),
        establishmentType: _selectedEstablishmentType,
        catalogs: BranchCatalogs(
          brands: _selectedBrandIds,
          displacementRanges: _selectedDisplacementRanges,
        ),
        location: BranchLocation(
          address: _addressController.text.trim(),
          cityId: _selectedCityId!,
          cityName: selectedCity.name,
          departmentId: _selectedDepartmentId!,
          departmentName: selectedDepartment.name,
        ),
        profileImageUrl: profileImageUrl,
      );

      if (!mounted) return;

      _editBranchBloc.add(
        EditBranchSubmitted(branchId: widget.branch.id!, branch: updatedBranch),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _editBranchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(BranchConstants.editBranchTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: BlocConsumer<EditBranchBloc, EditBranchState>(
          listener: (context, state) {
            ScaffoldMessenger.of(context).clearSnackBars();

            if (state is EditBranchSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(BranchConstants.branchUpdatedSuccess),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Navigate back with the updated branch
              Navigator.pop(context, state.updatedBranch);
            } else if (state is EditBranchFailure) {
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
            final isLoading = state is EditBranchLoading || _isUploadingImage;

            return BranchFormBody(
              formKey: _formKey,
              nameController: _nameController,
              addressController: _addressController,
              selectedImage: _selectedImage,
              existingImageUrl: _uploadedImageUrl,
              onImageChanged: (file) {
                setState(() => _selectedImage = file);
              },
              isUploadingImage: _isUploadingImage,
              selectedEstablishmentType: _selectedEstablishmentType,
              availableBranchTypes: availableBranchTypes,
              isLoadingBranchTypes: isLoadingBranchTypes,
              branchTypesError: branchTypesError,
              onEstablishmentTypeChanged: (value) {
                setState(() => _selectedEstablishmentType = value);
              },
              availableDepartments: availableDepartments,
              selectedDepartmentId: _selectedDepartmentId,
              isLoadingDepartments: isLoadingDepartments,
              departmentsError: departmentsError,
              onDepartmentChanged: (value) {
                setState(() {
                  _selectedDepartmentId = value;
                  _selectedCityId = null;
                });
                if (value != null) loadCities(value);
              },
              availableCities: availableCities,
              selectedCityId: _selectedCityId,
              isLoadingCities: isLoadingCities,
              citiesError: citiesError,
              onCityChanged: (value) {
                setState(() => _selectedCityId = value);
              },
              availableBrands: availableBrands,
              selectedBrandIds: _selectedBrandIds,
              onBrandsChanged: (brandIds) {
                setState(() => _selectedBrandIds = brandIds);
              },
              isLoadingBrands: isLoadingBrands,
              brandsError: brandsError,
              availableDisplacementRanges: availableDisplacementRanges,
              selectedDisplacementRanges: _selectedDisplacementRanges,
              onDisplacementRangesChanged: (ranges) {
                setState(() => _selectedDisplacementRanges = ranges);
              },
              isLoadingDisplacementRanges: isLoadingDisplacementRanges,
              displacementRangesError: displacementRangesError,
              isLoading: isLoading,
              onSubmit: _onSubmit,
              submitButtonTitle: _isUploadingImage
                  ? BranchConstants.uploadingImage
                  : BranchConstants.updateBranchButton,
              submitButtonIcon: const Icon(Icons.save, color: Colors.white),
              onCancel: () => Navigator.pop(context),
            );
          },
        ),
      ),
    );
  }
}
