import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/widgets/app_drawer.dart';
import 'package:motogo_frontend/src/core/widgets/shared_drawer_menu_items.dart';
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
        // Shared menu items (Edit Profile, Change Password, etc.)
        ...SharedDrawerMenuItems.commonItems(context),
        // User-specific: My Motorcycles
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
      ],
    );
  }
}
