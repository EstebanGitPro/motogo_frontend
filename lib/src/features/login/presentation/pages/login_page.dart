import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/hello.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/user_type_selection_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/verification_page.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback? onSwitchToRegister;
  const LoginPage({super.key, this.onSwitchToRegister});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error.message)));
          } else if (state is LoginNeedsVerification) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationPage(email: emailController.text),
              ),
            );
          } else if (state is LoginSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HolaApi()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is LoginInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LoginBloc>().add(
                            LoginSubmitted(
                              emailController.text,
                              passwordController.text,
                            ),
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserTypeSelectionPage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('Registrarse'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
