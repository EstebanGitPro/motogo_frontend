import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/branch_type_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/core/validators/validators.dart';
import 'package:motogo_frontend/src/core/widgets/button_widget.dart';
import 'package:motogo_frontend/src/core/widgets/image_picker_widget.dart';
import 'package:motogo_frontend/src/core/widgets/input_widgat.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_bloc.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_event.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/branch_type_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/brands_selector.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/city_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/department_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/displacement_range_selector.dart';
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

class _EditBranchPageState extends State<EditBranchPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;

  // Form state - initialized from existing branch
  String? _selectedEstablishmentType;
  List<String> _selectedBrandIds = [];
  List<String> _selectedDisplacementRanges = [];

  // Brands catalog state
  List<BrandEntity> _availableBrands = [];
  bool _isLoadingBrands = true;
  String? _brandsError;

  // Departments catalog state
  List<DepartmentEntity> _availableDepartments = [];
  bool _isLoadingDepartments = true;
  String? _departmentsError;
  String? _selectedDepartmentId;

  // Cities catalog state
  List<CityEntity> _availableCities = [];
  bool _isLoadingCities = false;
  String? _citiesError;
  String? _selectedCityId;

  // Branch types catalog state
  List<BranchTypeEntity> _availableBranchTypes = [];
  bool _isLoadingBranchTypes = true;
  String? _branchTypesError;

  // Displacement ranges catalog state
  List<DisplacementRangeEntity> _availableDisplacementRanges = [];
  bool _isLoadingDisplacementRanges = true;
  String? _displacementRangesError;

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
    _loadBrands();
    _loadDepartments();
    _loadBranchTypes();
    _loadDisplacementRanges();
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
      _loadCities(_selectedDepartmentId!);
    }
  }

  Future<void> _loadBrands() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getBrands();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isLoadingBrands = false;
          _brandsError = error.message;
        });
      },
      (brands) {
        setState(() {
          _isLoadingBrands = false;
          _availableBrands = brands;
        });
      },
    );
  }

  Future<void> _loadDepartments() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getDepartments();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isLoadingDepartments = false;
          _departmentsError = error.message;
        });
      },
      (departments) {
        setState(() {
          _isLoadingDepartments = false;
          _availableDepartments = departments;
        });
      },
    );
  }

  Future<void> _loadBranchTypes() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getBranchTypes();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isLoadingBranchTypes = false;
          _branchTypesError = error.message;
        });
      },
      (types) {
        setState(() {
          _isLoadingBranchTypes = false;
          _availableBranchTypes = types;
        });
      },
    );
  }

  Future<void> _loadDisplacementRanges() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getDisplacementRanges();

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isLoadingDisplacementRanges = false;
          _displacementRangesError = error.message;
        });
      },
      (ranges) {
        setState(() {
          _isLoadingDisplacementRanges = false;
          _availableDisplacementRanges = ranges;
        });
      },
    );
  }

  Future<void> _loadCities(String departmentId) async {
    setState(() {
      _isLoadingCities = true;
      _citiesError = null;
      // Don't clear cities if hydrating
      if (_availableCities.isEmpty) {
        _availableCities = [];
      }
    });

    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getCitiesByDepartment(departmentId);

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isLoadingCities = false;
          _citiesError = error.message;
        });
      },
      (cities) {
        setState(() {
          _isLoadingCities = false;
          _availableCities = cities;
        });
      },
    );
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
                content: Text('Error al subir imagen: ${error.message}'),
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
      final selectedCity = _availableCities.firstWhere(
        (c) => c.id == _selectedCityId,
        orElse: () => CityEntity(
          id: _selectedCityId!,
          name: widget.branch.cityName ?? '',
        ),
      );
      final selectedDepartment = _availableDepartments.firstWhere(
        (d) => d.id == _selectedDepartmentId,
        orElse: () => DepartmentEntity(
          id: _selectedDepartmentId!,
          name: widget.branch.departmentName ?? '',
        ),
      );

      final updatedBranch = widget.branch.copyWith(
        name: _nameController.text.trim(),
        establishmentType: _selectedEstablishmentType,
        brands: _selectedBrandIds,
        displacementRanges: _selectedDisplacementRanges,
        address: _addressController.text.trim(),
        cityId: _selectedCityId,
        cityName: selectedCity.name,
        departmentId: _selectedDepartmentId,
        departmentName: selectedDepartment.name,
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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile image picker
                      ImagePickerWidget(
                        selectedImage: _selectedImage,
                        existingImageUrl: _uploadedImageUrl,
                        onImageChanged: (file) {
                          setState(() {
                            _selectedImage = file;
                          });
                        },
                        enabled: !isLoading,
                        isUploading: _isUploadingImage,
                        label: BranchConstants.branchImageLabel,
                        hint: BranchConstants.branchImageHint,
                      ),
                      const SizedBox(height: 24),

                      // Branch name
                      CustomInputWidget(
                        controller: _nameController,
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
                        selectedValue: _selectedEstablishmentType,
                        branchTypes: _availableBranchTypes,
                        isLoading: _isLoadingBranchTypes,
                        errorMessage: _branchTypesError,
                        onChanged: (value) {
                          setState(() {
                            _selectedEstablishmentType = value;
                          });
                        },
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Address
                      CustomInputWidget(
                        controller: _addressController,
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
                        departments: _availableDepartments,
                        selectedDepartmentId: _selectedDepartmentId,
                        onChanged: (value) {
                          setState(() {
                            _selectedDepartmentId = value;
                            _selectedCityId = null;
                            _availableCities = [];
                          });
                          if (value != null) {
                            _loadCities(value);
                          }
                        },
                        enabled: !isLoading,
                        isLoading: _isLoadingDepartments,
                        errorMessage: _departmentsError,
                      ),
                      const SizedBox(height: 16),

                      // City dropdown (cascading)
                      CityDropdown(
                        cities: _availableCities,
                        selectedCityId: _selectedCityId,
                        onChanged: (value) {
                          setState(() {
                            _selectedCityId = value;
                          });
                        },
                        enabled: !isLoading,
                        isLoading: _isLoadingCities,
                        errorMessage: _citiesError,
                        hasDepartmentSelected: _selectedDepartmentId != null,
                      ),
                      const SizedBox(height: 24),

                      // Brands selector
                      BrandsSelector(
                        availableBrands: _availableBrands,
                        selectedBrandIds: _selectedBrandIds,
                        onChanged: (brandIds) {
                          setState(() {
                            _selectedBrandIds = brandIds;
                          });
                        },
                        enabled: !isLoading,
                        isLoading: _isLoadingBrands,
                        errorMessage: _brandsError,
                      ),
                      const SizedBox(height: 24),

                      // Displacement range selector
                      DisplacementRangeSelector(
                        availableRanges: _availableDisplacementRanges,
                        selectedRanges: _selectedDisplacementRanges,
                        onChanged: (ranges) {
                          setState(() {
                            _selectedDisplacementRanges = ranges;
                          });
                        },
                        enabled: !isLoading,
                        isLoading: _isLoadingDisplacementRanges,
                        errorMessage: _displacementRangesError,
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      CustomButtonWidget(
                        title: _isUploadingImage
                            ? BranchConstants.uploadingImage
                            : BranchConstants.updateBranchButton,
                        isLoading: isLoading,
                        onPressed: _onSubmit,
                        icon: const Icon(Icons.save, color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Cancel button
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: Text(
                          BranchConstants.cancel,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
