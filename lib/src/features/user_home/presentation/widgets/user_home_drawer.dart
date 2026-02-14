import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/widgets/app_drawer.dart';
import 'package:motogo_frontend/src/core/widgets/delete_account_dialog.dart';
import 'package:motogo_frontend/src/core/widgets/logout_dialog.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/pages/change_password_page.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/pages/edit_profile_page.dart';
import 'package:motogo_frontend/src/features/legal/presentation/pages/legal_page.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/presentation/pages/my_motorcycles_page.dart';

/// Drawer widget for the User Home page.
///
/// Displays the main navigation menu with links to profile, motorcycles,
/// password change, account deletion, and legal pages.
class UserHomeDrawer extends StatelessWidget {
  const UserHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDrawer(
      header: const AppDrawerHeader(
        icon: Icons.account_circle,
        title: MotorcycleConstants.drawerTitle,
      ),
      menuItems: [
        ListTile(
          leading: const Icon(Icons.home, color: Colors.blue),
          title: const Text(
            MotorcycleConstants.menuHome,
            style: TextStyle(fontSize: 16),
          ),
          onTap: () => Navigator.pop(context),
        ),
        const Divider(),
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
              MaterialPageRoute(
                builder: (context) => const EditMyProfilePage(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.two_wheeler, color: Colors.blue),
          title: const Text(
            MotorcycleConstants.menuMyMotorcycle,
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyMotorcyclesPage(),
              ),
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
                  create: (context) =>
                      InjectorApp.resolve<ChangePasswordBloc>(),
                  child: const ChangePasswordPage(),
                ),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            MotorcycleConstants.menuDeleteAccount,
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
          onTap: () {
            Navigator.pop(context);
            showDeleteAccountDialog(context);
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
      ],
    );
  }
}
