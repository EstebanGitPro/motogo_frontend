import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/features/admin_home/presentation/pages/admin_home_page.dart';
import 'package:motogo_frontend/src/features/home/presentation/pages/home_page.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/pages/user_home_page.dart';
import 'package:motogo_frontend/src/core/constants/login_constants.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/widgets/login_form.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/verification_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onSwitchToRegister;
  const LoginPage({super.key, this.onSwitchToRegister});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar - no hardcoded text on top
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          // Limpiar SnackBars anteriores
          ScaffoldMessenger.of(context).clearSnackBars();

          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(
                  seconds: LoginConstants.snackbarDurationSeconds,
                ),
              ),
            );
          } else if (state is LoginNeedsVerification) {
            // Navegar a la pantalla de verificación
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VerificationPage(email: _emailController.text),
              ),
            );
          } else if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(
                  seconds: LoginConstants.successSnackbarDurationSeconds,
                ),
              ),
            );

            // Conditional routing based on user role
            final userRole = state.user.role.toLowerCase();
            final Widget targetPage = switch (userRole) {
              AdminConstants.roleAdmin => const AdminHomePage(),
              AdminConstants.roleMotorcyclist => const UserHomePage(),
              _ => const HomePage(), // REPRESENTATIVE and other roles
            };

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => targetPage),
              (route) => false,
            );
          }
          if (state is LoginLoggedOut) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is LoginInProgress) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    getTranslateText(
                      context: context,
                      key: LoginTranslationKeys.loggingIn,
                    ),
                  ),
                ],
              ),
            );
          }

          return LoginForm(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
            state: state,
          );
        },
      ),
    );
  }
}
