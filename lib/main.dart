import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/hello.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/bloc/register_bloc.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/register_representative_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/register_user_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/user_type_selection_page.dart';

void main() {
  InjectorApp.setup();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(
          create: (_) =>
              LoginBloc(InjectorApp.resolve(), InjectorApp.resolve()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MotoGo',
        initialRoute: '/',
        routes: {
          '/': (context) => const UserTypeSelectionPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HolaApi(),
          '/register/user': (context) => const RegisterUserPage(),
          '/register/representative': (context) =>
              const RegisterRepresentativePage(),
        },
      ),
    ),
  );
}
