import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/pages/edit_profile_page.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/hello.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/bloc/register_bloc.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/register_representative_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/register_user_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/pages/user_type_selection_page.dart';

void main() {
  InjectorApp.setup();

  //const _testRoute = '/';
  //const _testRoute = '/edit-my-profile';
  // const _testRoute = '/login';
  // const _testRoute = '/home';

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => EditProfileBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MotoGo',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        //initialRoute: _testRoute,
        routes: {
          '/': (context) => const UserTypeSelectionPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HolaApi(),
          '/register/user': (context) => const RegisterUserPage(),
          '/register/representative': (context) =>
              const RegisterRepresentativePage(),

          '/edit-my-profile': (context) => const EditMyProfilePage(),
        },
      ),
    ),
  );
}
