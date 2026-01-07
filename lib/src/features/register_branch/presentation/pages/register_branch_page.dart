import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/brand_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/city_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/department_entity.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/firebase/storage_service.dart';
import 'package:motogo_frontend/src/core/validators/validators.dart';
import 'package:motogo_frontend/src/core/widgets/button_widget.dart';
import 'package:motogo_frontend/src/core/widgets/image_picker_widget.dart';
import 'package:motogo_frontend/src/core/widgets/input_widgat.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_bloc.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_event.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_state.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/branch_type_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/brands_selector.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/city_dropdown.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/widgets/department_dropdown.dart';
import 'package:uuid/uuid.dart';

/// Page for registering a new branch (sede).
class RegisterBranchPage extends StatefulWidget {
  const RegisterBranchPage({super.key});

  @override
  State<RegisterBranchPage> createState() => _RegisterBranchPageState();
}

class _RegisterBranchPageState extends State<RegisterBranchPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // Form state
  String? _selectedEstablishmentType;
  List<String> _selectedBrandIds = [];

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

  // Image state
  File? _selectedImage;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadDepartments();
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

  Future<void> _loadCities(String departmentId) async {
    setState(() {
      _isLoadingCities = true;
      _citiesError = null;
      _availableCities = [];
      _selectedCityId = null;
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
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBrandIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona al menos una marca'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedCityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona departamento y ciudad'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String? profileImageUrl = _uploadedImageUrl;

      // Upload image if selected and not already uploaded
      if (_selectedImage != null && _uploadedImageUrl == null) {
        setState(() => _isUploadingImage = true);

        final storageService = InjectorApp.resolve<StorageService>();

        // Generate a temporary ID for the upload path
        final tempBranchId = const Uuid().v4();

        final uploadResult = await storageService.uploadBranchImage(
          branchId: tempBranchId,
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
                  label: 'Reintentar',
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
        if (profileImageUrl == null && _selectedImage != null) {
          return;
        }
      }

      final branch = BranchEntity(
        name: _nameController.text.trim(),
        establishmentType: _selectedEstablishmentType!,
        brands: _selectedBrandIds,
        address: _addressController.text.trim(),
        cityId: _selectedCityId!,
        departmentId: _selectedDepartmentId,
        profileImageUrl: profileImageUrl,
      );

      if (!mounted) return;

      context.read<RegisterBranchBloc>().add(
        RegisterBranchSubmitted(branch: branch),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Sede'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocConsumer<RegisterBranchBloc, RegisterBranchState>(
        listener: (context, state) {
          ScaffoldMessenger.of(context).clearSnackBars();

          if (state is RegisterBranchSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate back after success
            Navigator.pop(context, true);
          } else if (state is RegisterBranchFailure) {
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
          final isLoading = state is RegisterBranchLoading || _isUploadingImage;

          return Container(
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
                      onImageChanged: (file) {
                        setState(() {
                          _selectedImage = file;
                          _uploadedImageUrl = null; // Reset if changed
                        });
                      },
                      enabled: !isLoading,
                      isUploading: _isUploadingImage,
                      label: 'Imagen de la Sede',
                      hint: 'Toca para agregar una imagen',
                    ),
                    const SizedBox(height: 24),

                    // Branch name
                    CustomInputWidget(
                      controller: _nameController,
                      labelText: 'Nombre de la Sede',
                      hintText: 'Ej: MotoGo Centro',
                      prefixIcon: const Icon(Icons.business_outlined),
                      enabled: !isLoading,
                      validator: ValidatorUtils.required(
                        customMessage: 'Por favor ingresa el nombre de la sede',
                      ).validate,
                    ),
                    const SizedBox(height: 16),

                    // Establishment type dropdown
                    BranchTypeDropdown(
                      selectedValue: _selectedEstablishmentType,
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
                      labelText: 'Dirección',
                      hintText: 'Ej: Calle 123 #45-67',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      enabled: !isLoading,
                      validator: ValidatorUtils.required(
                        customMessage: 'Por favor ingresa la dirección',
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

                    // Brands selector - Now loads from API!
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
                    const SizedBox(height: 32),

                    // Submit button
                    CustomButtonWidget(
                      title: _isUploadingImage
                          ? 'Subiendo imagen...'
                          : 'Crear Sede',
                      isLoading: isLoading,
                      onPressed: _onSubmit,
                      icon: const Icon(Icons.add_business, color: Colors.white),
                    ),
                    const SizedBox(height: 16),

                    // Cancel button
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
