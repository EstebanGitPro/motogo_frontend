// .../register/presentation/pages/register_user_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/verification_page.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/widgets/register_form.dart';

class RegisterUserPage extends StatelessWidget {
  final VoidCallback? onSwitchToLogin;
  const RegisterUserPage({super.key, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Registro Motociclista',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<RegisterPersonBloc, RegisterPersonState>(
        listener: (context, state) {
          if (state is RegisterPersonSuccess) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationPage(email: state.email),
              ),
            );
          } else if (state is RegisterPersonFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorModel.message),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 16,
                ),
              ),
            );
          }
        },

        child: const RegisterForm(
          role: 'user',
          title: 'Crear cuenta',
          subtitle: 'Completa tus datos para comenzar a usar MotoGo',
          buttonText: 'Crear cuenta',
          primaryColor: Colors.blue,
          icon: Icons.motorcycle,
        ),
      ),
    );
  }
}
