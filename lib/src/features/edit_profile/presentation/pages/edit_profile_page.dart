import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/widgets/action_buttons.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/widgets/editable_field.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/widgets/profile_header.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/widgets/read_only_field.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/widgets/verification_badge.dart';

class EditMyProfilePage extends StatelessWidget {
  const EditMyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar el BlocProvider que ya existe en el árbol de widgets
    return BlocBuilder<EditProfileBloc, EditProfileState>(
      builder: (context, state) {
        // Inicializar el bloc si es necesario
        if (state.status == EditProfileStatus.initial) {
          context.read<EditProfileBloc>().add(const EditProfileLoaded());
        }

        return const _EditProfileView();
      },
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _secondLastNameController;
  late TextEditingController _phoneController;

  final _formKey = GlobalKey<FormState>();

  // Para trackear los valores originales y detectar cambios
  String _originalFirstName = '';
  String _originalLastName = '';
  String _originalSecondLastName = '';
  String _originalPhone = '';

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _secondLastNameController = TextEditingController();
    _phoneController = TextEditingController();

    // Agregar listeners para detectar cambios
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _secondLastNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {}); // Para actualizar la UI cuando hay cambios
  }

  void _updateControllersWithPersonData(person) {
    if (!_controllersInitialized) {
      _firstNameController.text = person.firstName ?? '';
      _lastNameController.text = person.lastName ?? '';
      _secondLastNameController.text = person.secondLastName ?? '';
      _phoneController.text = person.phoneNumber ?? '';

      // Guardar valores originales
      _originalFirstName = person.firstName ?? '';
      _originalLastName = person.lastName ?? '';
      _originalSecondLastName = person.secondLastName ?? '';
      _originalPhone = person.phoneNumber ?? '';

      _controllersInitialized = true;
    }
  }

  bool get _hasChanges {
    if (!_controllersInitialized) return false;

    return _firstNameController.text.trim() != _originalFirstName ||
        _lastNameController.text.trim() != _originalLastName ||
        _secondLastNameController.text.trim() != _originalSecondLastName ||
        _phoneController.text.trim() != _originalPhone;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileBloc, EditProfileState>(
      listener: (context, state) {
        if (state.status == EditProfileStatus.success && _hasChanges) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isFromCache
                    ? 'Datos cargados desde caché'
                    : 'Perfil actualizado exitosamente',
              ),
              backgroundColor: state.isFromCache ? Colors.orange : Colors.green,
            ),
          );

          // Actualizar valores originales después de guardar
          if (!state.isFromCache) {
            _originalFirstName = _firstNameController.text.trim();
            _originalLastName = _lastNameController.text.trim();
            _originalSecondLastName = _secondLastNameController.text.trim();
            _originalPhone = _phoneController.text.trim();
          }
        }

        if (state.status == EditProfileStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'Error desconocido'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<EditProfileBloc, EditProfileState>(
        builder: (context, state) {
          final status = state.status;
          final person = state.person;

          if (status == EditProfileStatus.loading && person == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (person == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error ?? 'Error desconocido'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<EditProfileBloc>().add(
                        const EditProfileLoaded(forceRefresh: true),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Actualizar controladores con datos de la persona
          _updateControllersWithPersonData(person);

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text('Editar mis datos'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              actions: [
                // Indicador de caché
                if (state.isFromCache)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.orange),
                    tooltip: 'Actualizar desde servidor',
                    onPressed: () => context.read<EditProfileBloc>().add(
                      const EditProfileLoaded(forceRefresh: true),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ProfileHeader(
                            title: 'Editar mis datos',
                            subtitle: state.isFromCache
                                ? 'Datos desde caché - toca el ícono de actualizar para obtener la versión más reciente'
                                : 'Actualiza tu información personal',
                            roleDisplayName: '',
                            primaryColor: Theme.of(context).colorScheme.primary,
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 32),

                          ReadOnlyField(
                            label: 'Número de identificación',
                            value: person.identityNumber,
                            prefixIcon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 20),

                          EditableField(
                            controller: _firstNameController,
                            label: 'Nombres',
                            prefixIcon: Icons.person_outline,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'Campo requerido'
                                : null,
                            primaryColor: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),

                          EditableField(
                            controller: _lastNameController,
                            label: 'Primer apellido',
                            prefixIcon: Icons.person_outline,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'Campo requerido'
                                : null,
                            primaryColor: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),

                          EditableField(
                            controller: _secondLastNameController,
                            label: 'Segundo apellido (opcional)',
                            prefixIcon: Icons.person_outline,
                            primaryColor: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),

                          ReadOnlyField(
                            label: 'Correo electrónico',
                            value: person.email,
                            prefixIcon: Icons.email_outlined,
                            suffixIcon: VerificationBadge(person.emailVerified),
                          ),
                          const SizedBox(height: 16),

                          EditableField(
                            controller: _phoneController,
                            label: 'Número de teléfono',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: (v) => v?.trim().isEmpty == true
                                ? 'Campo requerido'
                                : null,
                            primaryColor: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          VerificationBadge(person.phoneNumberVerified),
                          const SizedBox(height: 32),

                          ActionButtons(
                            hasChanges: _hasChanges,
                            isLoading: status == EditProfileStatus.loading,
                            onSave: () {
                              if (_hasChanges) {
                                _onSave(person);
                              }
                            },
                            onCancel: () => _onCancel(context),
                          ),
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

  void _onSave(person) {
    if (!_formKey.currentState!.validate()) return;

    final updated = person.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      secondLastName: _secondLastNameController.text.trim().isEmpty
          ? null
          : _secondLastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    context.read<EditProfileBloc>().add(EditProfileSaved(updated));
  }

  void _onCancel(BuildContext context) async {
    if (_hasChanges) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Descartar cambios'),
          content: const Text(
            '¿Estás seguro de que quieres descartar los cambios?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Descartar'),
            ),
          ],
        ),
      );

      if (shouldDiscard == true) {
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}
