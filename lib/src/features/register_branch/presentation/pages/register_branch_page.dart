import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/mixins/catalog_loader_mixin.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/core/widgets/branch_form_body.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_bloc.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_event.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_state.dart';
import 'package:uuid/uuid.dart';

/// Page for registering a new branch (sede).
class RegisterBranchPage extends StatefulWidget {
  const RegisterBranchPage({super.key});

  @override
  State<RegisterBranchPage> createState() => _RegisterBranchPageState();
}

class _RegisterBranchPageState extends State<RegisterBranchPage>
    with CatalogLoaderMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // Form state
  String? _selectedEstablishmentType;
  List<String> _selectedBrandIds = [];
  List<String> _selectedDisplacementRanges = [];
  String? _selectedDepartmentId;
  String? _selectedCityId;

  // Image state
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    loadAllCatalogs();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_validateCatalogs()) return;

    String? profileImageUrl = await _resolveImageUrl();
    if (profileImageUrl == null && _selectedImage != null) return;

    // Get selected city and department names for geocoding
    final selectedCity = availableCities.firstWhere(
      (c) => c.id == _selectedCityId,
    );
    final selectedDepartment = availableDepartments.firstWhere(
      (d) => d.id == _selectedDepartmentId,
    );

    final branch = BranchEntity(
      name: _nameController.text.trim(),
      establishmentType: _selectedEstablishmentType!,
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

    context.read<RegisterBranchBloc>().add(
      RegisterBranchSubmitted(branch: branch),
    );
  }

  bool _validateCatalogs() {
    if (_selectedBrandIds.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(BranchConstants.brandRequired),
            backgroundColor: Colors.orange,
          ),
        );
      return false;
    }
    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(BranchConstants.locationRequired),
            backgroundColor: Colors.orange,
          ),
        );
      return false;
    }
    return true;
  }

  /// Uploads the selected image if needed, and returns the profile image URL.
  /// Returns null if the upload fails and an image was selected.
  Future<String?> _resolveImageUrl() async {
    if (_selectedImage == null || _uploadedImageUrl != null) {
      return _uploadedImageUrl;
    }

    setState(() => _isUploadingImage = true);

    final storageService = InjectorApp.resolve<StorageService>();
    final tempBranchId = const Uuid().v4();

    final uploadResult = await storageService.uploadBranchImage(
      branchId: tempBranchId,
      file: _selectedImage!,
    );

    if (!mounted) return null;

    return uploadResult.fold(
      (error) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
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
        return null;
      },
      (url) {
        setState(() {
          _isUploadingImage = false;
          _uploadedImageUrl = url;
        });
        return url;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(BranchConstants.createBranchTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocConsumer<RegisterBranchBloc, RegisterBranchState>(
        listener: (context, state) {
          ScaffoldMessenger.of(context).clearSnackBars();

          if (state is RegisterBranchSuccess) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            // Navigate back after success
            Navigator.pop(context, true);
          } else if (state is RegisterBranchFailure) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.error.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterBranchLoading || _isUploadingImage;

          return BranchFormBody(
            formKey: _formKey,
            nameController: _nameController,
            addressController: _addressController,
            selectedImage: _selectedImage,
            onImageChanged: (file) {
              setState(() {
                _selectedImage = file;
                _uploadedImageUrl = null; // Reset if changed
              });
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
                : BranchConstants.createBranchButton,
            submitButtonIcon: const Icon(
              Icons.add_business,
              color: Colors.white,
            ),
            onCancel: () => Navigator.pop(context),
          );
        },
      ),
    );
  }
}
