import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/constants/person_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/widgets/delete_account_dialog.dart';
import 'package:motogo_frontend/src/core/widgets/logout_dialog.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/pages/change_password_page.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/pages/edit_profile_page.dart';
import 'package:motogo_frontend/src/features/legal/presentation/pages/legal_page.dart';

/// Shared drawer menu items used across multiple drawers in the app.
///
/// Eliminates duplication between [UserHomeDrawer] and [HomePage] drawers.
class SharedDrawerMenuItems {
  SharedDrawerMenuItems._();

  /// Returns the common menu items shared between user-facing drawers.
  ///
  /// Includes: Edit Profile, Change Password, Delete Account, Logout, About.
  /// The [deleteAccountLabel] allows customization per context.
  static List<Widget> commonItems(
    BuildContext context, {
    String deleteAccountLabel = PersonConstants.deleteAccountMenuTitle,
  }) {
    return [
      ListTile(
        leading: const Icon(Icons.edit, color: Colors.blue),
        title: const Text(
          MotorcycleConstants.menuEditProfile,
          style: TextStyle(fontSize: 16),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditMyProfilePage()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.lock, color: Colors.blue),
        title: const Text(
          MotorcycleConstants.menuChangePassword,
          style: TextStyle(fontSize: 16),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => InjectorApp.resolve<ChangePasswordBloc>(),
                child: const ChangePasswordPage(),
              ),
            ),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.blue),
        title: const Text(
          MotorcycleConstants.menuLogout,
          style: TextStyle(fontSize: 16),
        ),
        onTap: () => showLogoutConfirmDialog(context),
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.info, color: Colors.blue),
        title: const Text(
          MotorcycleConstants.menuAbout,
          style: TextStyle(fontSize: 16),
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LegalPage()),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: Text(
          deleteAccountLabel,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
        onTap: () {
          Navigator.pop(context);
          showDeleteAccountDialog(context);
        },
      ),
    ];
  }
}
