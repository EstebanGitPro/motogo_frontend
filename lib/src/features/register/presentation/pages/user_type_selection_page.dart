import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';

class UserTypeSelectionPage extends StatelessWidget {
  final VoidCallback? onSwitchToLogin;
  const UserTypeSelectionPage({super.key, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              const SizedBox(height: 20),

              // Logo placeholder
              Container(
                height: 70,
                width: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.motorcycle,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'MotoGo',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '¿Cómo quieres usar MotoGo?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Selecciona el tipo de cuenta que mejor se adapte a tus necesidades',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Botones de selección
              _UserTypeButton(
                title: 'Soy Motociclista',
                subtitle: 'Busco servicios para mi moto',
                icon: Icons.motorcycle,
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/register/user');
                },
              ),

              const SizedBox(height: 16),

              _UserTypeButton(
                title: 'Represento una Sede',
                subtitle: 'Ofrezco servicios técnicos',
                icon: Icons.store,
                iconColor: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/register/representative');
                },
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes una cuenta?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('Iniciar sesión'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTypeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _UserTypeButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
