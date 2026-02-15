import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';

/// Shows a confirmation dialog for logging out.
///
/// Resets the [EditProfileBloc] and triggers [LoginLogout].
/// Navigates to `/login` clearing the full navigation stack.
void showLogoutConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginLoggedOut) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        builder: (context, state) {
          return AlertDialog(
            title: const Text(MotorcycleConstants.confirmLogoutTitle),
            content: const Text(MotorcycleConstants.confirmLogoutMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(CommonConstants.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<EditProfileBloc>().add(const EditProfileReset());
                  context.read<LoginBloc>().add(LoginLogout());
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text(MotorcycleConstants.menuLogout),
              ),
            ],
          );
        },
      );
    },
  );
}
