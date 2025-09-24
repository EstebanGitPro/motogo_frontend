import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/pages/edit_profile_page.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/home/presentation/pages/home_page.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/register_representative_page.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/register_user_page.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/user_type_selection_page.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/email_verification_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/code_validation_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/password_recovery_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/pages/email_verification_page.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/pages/code_verification_page.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/pages/password_reset_page.dart';

void main() {
  InjectorApp.setup();

  //const _testRoute = '/';
  //const _testRoute = '/edit-my-profile';
  // const _testRoute = '/login';
  // const _testRoute = '/home';

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RegisterPersonBloc()),
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => EditProfileBloc()),
        BlocProvider(create: (_) => EmailRecoveryVerificationBloc()),
        BlocProvider(create: (_) => CodeValidationBloc()),
        BlocProvider(create: (_) => PasswordRecoveryBloc()),
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
          '/home': (context) => const HomePage(),
          '/register/user': (context) => const RegisterUserPage(),
          '/register/representative': (context) =>
              const RegisterRepresentativePage(),
          '/edit-my-profile': (context) => const EditMyProfilePage(),
          '/password-recovery/email': (context) => const EmailRecoveryVerificationPage(),
          '/password-recovery/code': (context) => const CodeVerificationPage(email: ''),
          '/password-recovery/reset': (context) => const PasswordResetPage(email: '', verificationCode: ''),
        },
      ),
    ),
  );
}
