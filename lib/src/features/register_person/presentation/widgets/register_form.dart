import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/validators/validators.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/user_type_selection_page.dart';

class RegisterForm extends StatefulWidget {
  final String role;
  final String title;
  final String subtitle;
  final String buttonText;
  final Color primaryColor;
  final IconData icon;
  final Widget? extraContent;
  final VoidCallback? onSwitchToLogin;

  const RegisterForm({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.primaryColor,
    required this.icon,
    this.extraContent,
    this.onSwitchToLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _identityController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _secondLastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String get role => widget.role;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_forceLowercase);
  }

  void _forceLowercase() {
    final text = _emailController.text;
    final lower = text.toLowerCase();
    if (text != lower) {
      _emailController.value = _emailController.value.copyWith(
        text: lower,
        selection: _emailController.selection,
      );
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_forceLowercase);
    _identityController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validadores reutilizables
  final BaseValidator _identityValidator = ValidatorUtils.identity();
  final BaseValidator _nameValidator = ValidatorUtils.name();
  final BaseValidator _emailValidator = ValidatorUtils.email();
  final BaseValidator _phoneValidator = ValidatorUtils.phone();
  final BaseValidator _passwordValidator = ValidatorUtils.password();

  BaseValidator get _confirmPasswordValidator =>
      ValidatorUtils.confirmPassword(_passwordController.text);

  String? _validateIdentity(String? value) =>
      _identityValidator.validate(value);
  String? _validateName(String? value) => _nameValidator.validate(value);
  String? _validateEmail(String? value) => _emailValidator.validate(value);
  String? _validatePhone(String? value) => _phoneValidator.validate(value);
  String? _validatePassword(String? value) =>
      _passwordValidator.validate(value);
  String? _validateConfirmPassword(String? value) =>
      _confirmPasswordValidator.validate(value);

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<RegisterPersonBloc>().add(
        RegisterPersonSubmitted(
          identityNumber: _identityController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          secondLastName: _secondLastNameController.text.isEmpty
              ? null
              : _secondLastNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text,
          emailVerified: false,
          phoneNumberVerified: false,
          password: _passwordController.text,
          role: role,
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontSize: isMobile ? 16 : 18),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: isMobile ? 16 : 18,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey[600], size: 22)
            : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: widget.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 16 : 18,
        ),
      ),
    );
  }

  Widget _buildPasswordToggle(bool obscure, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.grey[600],
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isLargeScreen = screenSize.width > 800;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxFormWidth(screenSize)),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 5 : 32,
              vertical: isMobile ? 12 : 24,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, isMobile),
                      const SizedBox(height: 32),
                      _buildFormFields(isLargeScreen),
                      if (widget.extraContent != null) ...[
                        const SizedBox(height: 24),
                        widget.extraContent!,
                      ],
                      const SizedBox(height: 32),
                      _buildSubmitSection(isMobile),
                      const SizedBox(height: 32),
                      _buildLoginLink(isMobile),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Calculates the max form width based on screen size.
  double _maxFormWidth(Size screenSize) {
    if (screenSize.width > 800) return 600;
    if (screenSize.width > 600) return 500;
    return double.infinity;
  }

  /// Builds the form header with icon, title, and subtitle.
  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Center(
      child: Column(
        children: [
          Container(
            width: isMobile ? 60 : 70,
            height: isMobile ? 60 : 70,
            decoration: BoxDecoration(
              color: widget.primaryColor.withAlpha(38),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.icon,
              color: widget.primaryColor,
              size: isMobile ? 30 : 35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: isMobile ? 24 : 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              fontSize: isMobile ? 16 : 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Chooses between large-screen (side-by-side) or mobile (stacked) layout.
  Widget _buildFormFields(bool isLargeScreen) {
    if (isLargeScreen) return _buildLargeScreenFields();
    return _buildMobileFields();
  }

  /// Side-by-side field pairs for large screens.
  Widget _buildLargeScreenFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _identityController,
                label: 'Número de identificación',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.badge_outlined,
                validator: _validateIdentity,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'Nombres',
                prefixIcon: Icons.person_outline,
                validator: _validateName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'Primer apellido',
                prefixIcon: Icons.person_outline,
                validator: _validateName,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _secondLastNameController,
                label: 'Segundo apellido (Opcional)',
                prefixIcon: Icons.person_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: _validateEmail,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _phoneController,
                label: 'Número de teléfono',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: _validatePhone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _passwordController,
                label: 'Contraseña',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _buildPasswordToggle(
                  _obscurePassword,
                  () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: _validatePassword,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirmar contraseña',
                obscureText: _obscureConfirmPassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _buildPasswordToggle(
                  _obscureConfirmPassword,
                  () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Stacked field layout for mobile screens.
  Widget _buildMobileFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _identityController,
          label: 'Número de identificación',
          keyboardType: TextInputType.number,
          prefixIcon: Icons.badge_outlined,
          validator: _validateIdentity,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _firstNameController,
          label: 'Nombres',
          prefixIcon: Icons.person_outline,
          validator: _validateName,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _lastNameController,
          label: 'Primer apellido',
          prefixIcon: Icons.person_outline,
          validator: _validateName,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _secondLastNameController,
          label: 'Segundo apellido (Opcional)',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Correo electrónico',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Número de teléfono',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          validator: _validatePhone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: 'Contraseña',
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: _buildPasswordToggle(
            _obscurePassword,
            () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'Confirmar contraseña',
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: _buildPasswordToggle(
            _obscureConfirmPassword,
            () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword,
            ),
          ),
          validator: _validateConfirmPassword,
        ),
      ],
    );
  }

  /// Builds the submit button with error banner.
  Widget _buildSubmitSection(bool isMobile) {
    return BlocBuilder<RegisterPersonBloc, RegisterPersonState>(
      builder: (context, state) {
        final isLoading = state is RegisterPersonLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state is RegisterPersonFailure) ...[
              _buildErrorBanner(state),
              const SizedBox(height: 16),
            ],
            _buildSubmitButton(isLoading, isMobile),
          ],
        );
      },
    );
  }

  /// Builds the error banner for registration failures.
  Widget _buildErrorBanner(RegisterPersonFailure state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.errorModel.message,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (state.errorModel.description != null &&
              state.errorModel.description != state.errorModel.message) ...[
            const SizedBox(height: 4),
            Text(
              state.errorModel.description!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ],
          if (state.errorModel.fieldErrors != null) ...[
            const SizedBox(height: 8),
            ...state.errorModel.fieldErrors!.entries.map(
              (entry) => Text(
                '• ${entry.key}: ${entry.value}',
                style: TextStyle(color: Colors.red.shade600, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the submit elevated button.
  Widget _buildSubmitButton(bool isLoading, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: widget.primaryColor.withAlpha(75),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : _buildSubmitButtonContent(isMobile),
      ),
    );
  }

  /// Content of the submit button (icon + text).
  Widget _buildSubmitButtonContent(bool isMobile) {
    final iconSize = isMobile ? 20.0 : 22.0;
    final fontSize = isMobile ? 16.0 : 18.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icon, size: iconSize),
        const SizedBox(width: 8),
        Text(
          widget.buttonText,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Builds the "already have an account?" login link.
  Widget _buildLoginLink(bool isMobile) {
    return Center(
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '¿Ya tienes una cuenta? ',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
              TextButton(
                onPressed: state is LoginInProgress
                    ? null
                    : widget.onSwitchToLogin ??
                          () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserTypeSelectionPage(),
                              ),
                              (route) => false,
                            );
                          },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 4 : 8,
                    vertical: isMobile ? 0 : 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: widget.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
