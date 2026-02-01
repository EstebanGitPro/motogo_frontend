// 2. Campo editable con validación
import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final Color primaryColor;

  const EditableField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
    required this.primaryColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: TextStyle(
        fontSize: isMobile ? 16 : 18,
        color: enabled ? Colors.black87 : Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled ? Colors.grey[600] : Colors.grey[400],
          fontSize: isMobile ? 16 : 18,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: enabled ? Colors.grey[600] : Colors.grey[400],
                size: 22,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 2),
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
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isMobile ? 16 : 18,
        ),
      ),
    );
  }
}
