import 'package:flutter/material.dart';

class AdditionalOptions extends StatelessWidget {
  final VoidCallback onChangePassword;
  final VoidCallback onVerifyInfo;
  final bool showVerifyOption;

  const AdditionalOptions({
    required this.onChangePassword,
    required this.onVerifyInfo,
    this.showVerifyOption = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          TextButton.icon(
            onPressed: onChangePassword,
            icon: const Icon(Icons.lock_outline),
            label: const Text('Cambiar Contraseña'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (showVerifyOption) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onVerifyInfo,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Verificar Información'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ],
        ],
      ),
    );
  }
}