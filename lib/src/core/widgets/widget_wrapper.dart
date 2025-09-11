import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/user_type_selection_page.dart';

enum AuthMode { login, register }

class WidgetWrapper extends StatefulWidget {
  const WidgetWrapper({super.key});

  @override
  State<WidgetWrapper> createState() => _WidgetWrapperState();
}

class _WidgetWrapperState extends State<WidgetWrapper> {
  AuthMode _currentMode = AuthMode.login;

  void _switchToLogin() {
    setState(() {
      _currentMode = AuthMode.login;
    });
  }

  void _switchToRegister() {
    setState(() {
      _currentMode = AuthMode.register;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentMode) {
      case AuthMode.login:
        return LoginPage(onSwitchToRegister: _switchToRegister);
      case AuthMode.register:
        return UserTypeSelectionPage(onSwitchToLogin: _switchToLogin);
    }
  }
}
