import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/widgets/editable_field.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/widgets/read_only_field.dart';

class EditMyProfilePage extends StatelessWidget {
  const EditMyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProfileBloc, EditProfileState>(
      builder: (context, state) {
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

    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _secondLastNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {});
    });
  }

  void _updateControllersWithUserData(user) {
    if (!_controllersInitialized) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _secondLastNameController.text = user.secondLastName ?? '';
      _phoneController.text = user.phoneNumber;

      _originalFirstName = user.firstName;
      _originalLastName = user.lastName;
      _originalSecondLastName = user.secondLastName ?? '';
      _originalPhone = user.phoneNumber;

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

  void _handleBackButton() async {
    if (_hasChanges) {
      final shouldDiscard = await _showDiscardChangesDialog();
      if (shouldDiscard == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<bool?> _showDiscardChangesDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambios sin guardar'),
        content: const Text(
          'Tienes cambios sin guardar. ¿Deseas salir sin guardar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar editando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salir sin guardar'),
          ),
        ],
      ),
    );
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _handleBackButton();
        }
      },
      child: BlocListener<EditProfileBloc, EditProfileState>(
        listener: (context, state) {
          // Show success message from backend (for update operations)
          if (state.status == EditProfileStatus.success &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // Update original values after successful save
            _originalFirstName = _firstNameController.text.trim();
            _originalLastName = _lastNameController.text.trim();
            _originalSecondLastName = _secondLastNameController.text.trim();
            _originalPhone = _phoneController.text.trim();
          }

          if (state.status == EditProfileStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Error desconocido'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<EditProfileBloc, EditProfileState>(
          builder: (context, state) {
            final status = state.status;
            final user = state.user;

            if (status == EditProfileStatus.loading && user == null) {
              return Scaffold(
                backgroundColor: Colors.grey[50],
                appBar: AppBar(
                  title: const Text('Editar mis datos'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _handleBackButton,
                  ),
                ),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando datos del perfil...'),
                    ],
                  ),
                ),
              );
            }

            if (user == null) {
              return Scaffold(
                backgroundColor: Colors.grey[50],
                appBar: AppBar(
                  title: const Text('Editar mis datos'),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _handleBackButton,
                  ),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.error ?? 'Error desconocido',
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.read<EditProfileBloc>().add(
                          const EditProfileLoaded(forceRefresh: true),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            _updateControllersWithUserData(user);

            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                title: Row(
                  children: [
                    const Text('Editar mis datos'),
                    if (_hasChanges) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.withAlpha(5)),
                        ),
                        child: const Text(
                          'Cambios pendientes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _handleBackButton,
                ),
                actions: [
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
                            Column(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withAlpha(1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 40,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Editar mis datos',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.isFromCache
                                      ? 'Datos desde caché - toca el ícono de actualizar para obtener la versión más reciente'
                                      : 'Actualiza tu información personal',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            ReadOnlyField(
                              label: 'Número de identificación',
                              value: user.identityNumber,
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
                              primaryColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),

                            EditableField(
                              controller: _lastNameController,
                              label: 'Primer apellido',
                              prefixIcon: Icons.person_outline,
                              validator: (v) => v?.trim().isEmpty == true
                                  ? 'Campo requerido'
                                  : null,
                              primaryColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),

                            EditableField(
                              controller: _secondLastNameController,
                              label: 'Segundo apellido (opcional)',
                              prefixIcon: Icons.person_outline,
                              primaryColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),

                            ReadOnlyField(
                              label: 'Correo electrónico',
                              value: user.email,
                              prefixIcon: Icons.email_outlined,
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
                              primaryColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed:
                                    _hasChanges &&
                                        status != EditProfileStatus.loading
                                    ? () => _onSave(user)
                                    : null,
                                icon: status == EditProfileStatus.loading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: Text(
                                  status == EditProfileStatus.loading
                                      ? 'Guardando...'
                                      : 'Guardar cambios',
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),

                            if (!_hasChanges) ...[
                              const SizedBox(height: 16),
                              Text(
                                'No hay cambios para guardar',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  void _onSave(user) {
    if (!_formKey.currentState!.validate()) return;

    final updated = user.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      secondLastName: _secondLastNameController.text.trim().isEmpty
          ? null
          : _secondLastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    context.read<EditProfileBloc>().add(EditProfileSaved(updated));
  }
}
