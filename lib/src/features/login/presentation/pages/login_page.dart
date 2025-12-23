import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/features/home/presentation/pages/home_page.dart';
import 'package:motogo_frontend/src/features/login/core/constants/login_constants.dart';
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

  void _showVerificationDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            getTranslateText(
              context: context,
              key: LoginTranslationKeys.verificationRequired,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.email_outlined, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VerificationPage(email: _emailController.text),
                  ),
                );
              },
              child: Text(
                getTranslateText(
                  context: context,
                  key: LoginTranslationKeys.goToVerification,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                getTranslateText(
                  context: context,
                  key: LoginTranslationKeys.understood,
                ),
              ),
            ),
          ],
        );
      },
    );
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
            _showVerificationDialog(
              state.message ??
                  getTranslateText(
                    context: context,
                    key: LoginTranslationKeys.emailNotVerified,
                  ),
            );
          } else if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  getTranslateText(
                    context: context,
                    key: LoginTranslationKeys.loginSuccess,
                  ),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: Duration(
                  seconds: LoginConstants.successSnackbarDurationSeconds,
                ),
              ),
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
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
