import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/edit_profile_constants.dart';
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
        title: const Text(CommonConstants.unsavedChangesTitle),
        content: const Text(EditProfileConstants.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(CommonConstants.continueEditing),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(CommonConstants.exitWithoutSaving),
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
        listener: _onStateChanged,
        child: BlocBuilder<EditProfileBloc, EditProfileState>(
          builder: (context, state) => _buildContent(context, state),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, EditProfileState state) {
    if (state.status == EditProfileStatus.success &&
        state.successMessage != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

      _originalFirstName = _firstNameController.text.trim();
      _originalLastName = _lastNameController.text.trim();
      _originalSecondLastName = _secondLastNameController.text.trim();
      _originalPhone = _phoneController.text.trim();
    }

    if (state.status == EditProfileStatus.failure) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(state.error ?? CommonConstants.unknownError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
    }
  }

  Widget _buildContent(BuildContext context, EditProfileState state) {
    final status = state.status;
    final user = state.user;

    if (status == EditProfileStatus.loading && user == null) {
      return _buildLoadingScaffold();
    }
    if (user == null) {
      return _buildErrorScaffold(state.error);
    }

    _updateControllersWithUserData(user);
    return _buildProfileScaffold(context, state, user);
  }

  PreferredSizeWidget _buildAppBar({List<Widget>? actions}) {
    return AppBar(
      title: const Text(EditProfileConstants.pageTitle),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _handleBackButton,
      ),
      actions: actions,
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(EditProfileConstants.loadingProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String? error) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error ?? CommonConstants.unknownError,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<EditProfileBloc>().add(
                const EditProfileLoaded(forceRefresh: true),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(CommonConstants.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScaffold(
    BuildContext context,
    EditProfileState state,
    dynamic user,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            const Text(EditProfileConstants.pageTitle),
            if (_hasChanges) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withAlpha(5)),
                ),
                child: const Text(
                  EditProfileConstants.pendingChanges,
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
              tooltip: EditProfileConstants.refreshFromServer,
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
                    _buildProfileHeader(context, state),
                    const SizedBox(height: 32),
                    _buildFormFields(context, user),
                    const SizedBox(height: 32),
                    _buildSaveButton(context, state.status, user),
                    _buildNoChangesHint(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, EditProfileState state) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withAlpha(1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.person_outline,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          EditProfileConstants.pageTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.isFromCache
              ? EditProfileConstants.cacheNotice
              : EditProfileConstants.updatePrompt,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields(BuildContext context, dynamic user) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        ReadOnlyField(
          label: EditProfileConstants.identityNumberLabel,
          value: user.identityNumber,
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 20),
        EditableField(
          controller: _firstNameController,
          label: EditProfileConstants.firstNameLabel,
          prefixIcon: Icons.person_outline,
          validator: (v) =>
              v?.trim().isEmpty == true ? CommonConstants.fieldRequired : null,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),
        EditableField(
          controller: _lastNameController,
          label: EditProfileConstants.lastNameLabel,
          prefixIcon: Icons.person_outline,
          validator: (v) =>
              v?.trim().isEmpty == true ? CommonConstants.fieldRequired : null,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),
        EditableField(
          controller: _secondLastNameController,
          label: EditProfileConstants.secondLastNameLabel,
          prefixIcon: Icons.person_outline,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),
        ReadOnlyField(
          label: EditProfileConstants.emailLabel,
          value: user.email,
          prefixIcon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        EditableField(
          controller: _phoneController,
          label: EditProfileConstants.phoneLabel,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          validator: (v) =>
              v?.trim().isEmpty == true ? CommonConstants.fieldRequired : null,
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    EditProfileStatus status,
    dynamic user,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _hasChanges && status != EditProfileStatus.loading
            ? () => _onSave(user)
            : null,
        icon: status == EditProfileStatus.loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          status == EditProfileStatus.loading
              ? EditProfileConstants.saving
              : EditProfileConstants.saveChanges,
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildNoChangesHint() {
    if (_hasChanges) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        EditProfileConstants.noChanges,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
