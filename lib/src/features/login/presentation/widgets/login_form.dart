import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/validators/validators.dart';
import 'package:motogo_frontend/src/core/widgets/button_widget.dart';
import 'package:motogo_frontend/src/core/widgets/input_widgat.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/pages/email_verification_page.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/user_type_selection_page.dart';

class LoginForm extends StatefulWidget {
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
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    widget.emailController.addListener(_forceLowercase);
  }

  void _forceLowercase() {
    final text = widget.emailController.text;
    final lower = text.toLowerCase();
    if (text != lower) {
      widget.emailController.value = widget.emailController.value.copyWith(
        text: lower,
        selection: widget.emailController.selection,
      );
    }
  }

  @override
  void dispose() {
    widget.emailController.removeListener(_forceLowercase);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: widget.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'MotosGo',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomInputWidget(
                    controller: widget.emailController,
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    validator: ValidatorUtils.email().validate,
                  ),
                  const SizedBox(height: 16),

                  CustomInputWidget(
                    controller: widget.passwordController,
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: ValidatorUtils.required(
                      customMessage: 'Por favor ingresa tu contraseña',
                    ).validate,
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: widget.state is LoginInProgress
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EmailRecoveryVerificationPage(),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                    isLoading: widget.state is LoginInProgress,
                    onPressed: () {
                      if (widget.formKey.currentState!.validate()) {
                        context.read<LoginBloc>().add(
                          LoginSubmitted(
                            email: widget.emailController.text,
                            password: widget.passwordController.text,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text('¿No tienes una cuenta?'),
                      TextButton(
                        onPressed: widget.state is LoginInProgress
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
