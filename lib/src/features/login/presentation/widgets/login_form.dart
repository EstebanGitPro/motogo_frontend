import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/widgets/button_widget.dart';
import 'package:motogo_frontend/src/core/widgets/input_widgat.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/pages/email_verification_page.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/pages/email_verification_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/user_type_selection_page.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final LoginState state;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'MotoGo',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomInputWidget(
                    controller: emailController,
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomInputWidget(
                    controller: passwordController,
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  
                 
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: state is LoginInProgress
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmailRecoveryVerificationPage(),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  CustomButtonWidget(
                    title: 'Iniciar sesión',
                    isLoading: state is LoginInProgress,
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        context.read<LoginBloc>().add(
                          LoginSubmitted(
                            email: emailController.text,
                            password: passwordController.text,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿No tienes una cuenta?'),
                      TextButton(
                        onPressed: state is LoginInProgress
                            ? null
                            : () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const UserTypeSelectionPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
