// .../register/presentation/pages/register_user_page.dart

import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/helpers/register_person_listener.dart';
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
          getTranslateText(context: context, key: 'register_motorcyclist'),
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
      body: buildRegisterPersonListener(
        context: context,
        isMobile: isMobile,
        child: RegisterForm(
          role: 'user',
          title: getTranslateText(context: context, key: 'create_account'),
          subtitle: getTranslateText(
            context: context,
            key: 'complete_data_motogo',
          ),
          buttonText: getTranslateText(context: context, key: 'create_account'),
          primaryColor: Colors.blue,
          icon: Icons.motorcycle,
        ),
      ),
    );
  }
}
