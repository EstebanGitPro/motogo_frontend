import 'package:flutter/material.dart';

class PasswordResetWidget extends StatefulWidget {
  final Function(String password, String confirmPassword) onPasswordSubmit;
  final bool isLoading;

  const PasswordResetWidget({
    super.key,
    required this.onPasswordSubmit,
    this.isLoading = false,
  });

  @override
  State<PasswordResetWidget> createState() => _PasswordResetWidgetState();
}

class _PasswordResetWidgetState extends State<PasswordResetWidget> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'La contraseña debe contener al menos una mayúscula, una minúscula y un número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Widget _buildRequirement(String text, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 4 : 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: isMobile ? 16 : 18,
            color: Colors.blue[600],
          ),
          SizedBox(width: isMobile ? 8 : 10),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  void _submitPassword() {
    if (_formKey.currentState!.validate()) {
      widget.onPasswordSubmit(
        _passwordController.text,
        _confirmPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              hintText: 'Ingresa tu nueva contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          // Confirm password field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmar contraseña',
              hintText: 'Confirma tu nueva contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),

          SizedBox(height: isMobile ? 24 : 32),

          // Password requirements
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'La contraseña debe contener:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                _buildRequirement('Al menos 8 caracteres', isMobile),
                _buildRequirement('Una letra mayúscula', isMobile),
                _buildRequirement('Una letra minúscula', isMobile),
                _buildRequirement('Un número', isMobile),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 32 : 40),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: isMobile ? 50 : 56,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Actualizar contraseña',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}