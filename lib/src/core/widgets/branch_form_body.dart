import 'dart:io';

import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/validators/validators.dart';
import 'package:motogo_frontend/src/core/widgets/button_widget.dart';
import 'package:motogo_frontend/src/core/widgets/image_picker_widget.dart';
import 'package:motogo_frontend/src/core/widgets/input_widgat.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/branch_type_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/brands_selector.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/city_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/department_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/displacement_range_selector.dart';

/// Reusable form body shared between [RegisterBranchPage] and [EditBranchPage].
///
/// Encapsulates the common form fields (image picker, name, type, address,
/// location dropdowns, brands, displacement ranges) to eliminate duplication.
class BranchFormBody extends StatelessWidget {
  // Controllers
  final TextEditingController nameController;
  final TextEditingController addressController;

  // Form key
  final GlobalKey<FormState> formKey;

  // Image state
  final File? selectedImage;
  final String? existingImageUrl;
  final ValueChanged<File?> onImageChanged;
  final bool isUploadingImage;

  // Establishment type
  final String? selectedEstablishmentType;
  final List<BranchTypeEntity> availableBranchTypes;
  final bool isLoadingBranchTypes;
  final String? branchTypesError;
  final ValueChanged<String?> onEstablishmentTypeChanged;

  // Department / City cascading
  final List<DepartmentEntity> availableDepartments;
  final String? selectedDepartmentId;
  final bool isLoadingDepartments;
  final String? departmentsError;
  final ValueChanged<String?> onDepartmentChanged;

  final List<CityEntity> availableCities;
  final String? selectedCityId;
  final bool isLoadingCities;
  final String? citiesError;
  final ValueChanged<String?> onCityChanged;

  // Brands
  final List<BrandEntity> availableBrands;
  final List<String> selectedBrandIds;
  final ValueChanged<List<String>> onBrandsChanged;
  final bool isLoadingBrands;
  final String? brandsError;

  // Displacement ranges
  final List<DisplacementRangeEntity> availableDisplacementRanges;
  final List<String> selectedDisplacementRanges;
  final ValueChanged<List<String>> onDisplacementRangesChanged;
  final bool isLoadingDisplacementRanges;
  final String? displacementRangesError;

  // Loading / Submit
  final bool isLoading;
  final VoidCallback onSubmit;
  final String submitButtonTitle;
  final Icon submitButtonIcon;
  final VoidCallback onCancel;

  const BranchFormBody({
    super.key,
    required this.nameController,
    required this.addressController,
    required this.formKey,
    required this.selectedImage,
    this.existingImageUrl,
    required this.onImageChanged,
    required this.isUploadingImage,
    required this.selectedEstablishmentType,
    required this.availableBranchTypes,
    required this.isLoadingBranchTypes,
    this.branchTypesError,
    required this.onEstablishmentTypeChanged,
    required this.availableDepartments,
    this.selectedDepartmentId,
    required this.isLoadingDepartments,
    this.departmentsError,
    required this.onDepartmentChanged,
    required this.availableCities,
    this.selectedCityId,
    required this.isLoadingCities,
    this.citiesError,
    required this.onCityChanged,
    required this.availableBrands,
    required this.selectedBrandIds,
    required this.onBrandsChanged,
    required this.isLoadingBrands,
    this.brandsError,
    required this.availableDisplacementRanges,
    required this.selectedDisplacementRanges,
    required this.onDisplacementRangesChanged,
    required this.isLoadingDisplacementRanges,
    this.displacementRangesError,
    required this.isLoading,
    required this.onSubmit,
    required this.submitButtonTitle,
    required this.submitButtonIcon,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile image picker
              ImagePickerWidget(
                selectedImage: selectedImage,
                existingImageUrl: existingImageUrl,
                onImageChanged: onImageChanged,
                enabled: !isLoading,
                isUploading: isUploadingImage,
                label: BranchConstants.branchImageLabel,
                hint: BranchConstants.branchImageHint,
              ),
              const SizedBox(height: 24),

              // Branch name
              CustomInputWidget(
                controller: nameController,
                labelText: BranchConstants.branchNameLabel,
                hintText: BranchConstants.branchNameHint,
                prefixIcon: const Icon(Icons.business_outlined),
                enabled: !isLoading,
                validator: ValidatorUtils.required(
                  customMessage: BranchConstants.branchNameRequired,
                ).validate,
              ),
              const SizedBox(height: 16),

              // Establishment type dropdown
              BranchTypeDropdown(
                selectedValue: selectedEstablishmentType,
                branchTypes: availableBranchTypes,
                isLoading: isLoadingBranchTypes,
                errorMessage: branchTypesError,
                onChanged: onEstablishmentTypeChanged,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),

              // Address
              CustomInputWidget(
                controller: addressController,
                labelText: BranchConstants.addressLabel,
                hintText: BranchConstants.addressHint,
                prefixIcon: const Icon(Icons.location_on_outlined),
                enabled: !isLoading,
                validator: ValidatorUtils.required(
                  customMessage: BranchConstants.addressRequired,
                ).validate,
              ),
              const SizedBox(height: 16),

              // Department dropdown
              DepartmentDropdown(
                departments: availableDepartments,
                selectedDepartmentId: selectedDepartmentId,
                onChanged: onDepartmentChanged,
                enabled: !isLoading,
                isLoading: isLoadingDepartments,
                errorMessage: departmentsError,
              ),
              const SizedBox(height: 16),

              // City dropdown (cascading)
              CityDropdown(
                cities: availableCities,
                selectedCityId: selectedCityId,
                onChanged: onCityChanged,
                enabled: !isLoading,
                isLoading: isLoadingCities,
                errorMessage: citiesError,
                hasDepartmentSelected: selectedDepartmentId != null,
              ),
              const SizedBox(height: 24),

              // Brands selector
              BrandsSelector(
                availableBrands: availableBrands,
                selectedBrandIds: selectedBrandIds,
                onChanged: onBrandsChanged,
                enabled: !isLoading,
                isLoading: isLoadingBrands,
                errorMessage: brandsError,
              ),
              const SizedBox(height: 24),

              // Displacement range selector
              DisplacementRangeSelector(
                availableRanges: availableDisplacementRanges,
                selectedRanges: selectedDisplacementRanges,
                onChanged: onDisplacementRangesChanged,
                enabled: !isLoading,
                isLoading: isLoadingDisplacementRanges,
                errorMessage: displacementRangesError,
              ),
              const SizedBox(height: 32),

              // Submit button
              CustomButtonWidget(
                title: submitButtonTitle,
                isLoading: isLoading,
                onPressed: onSubmit,
                icon: submitButtonIcon,
              ),
              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: isLoading ? null : onCancel,
                child: Text(
                  BranchConstants.cancel,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
