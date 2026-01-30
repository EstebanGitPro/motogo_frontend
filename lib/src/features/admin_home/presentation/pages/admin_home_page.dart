import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/admin_home/presentation/widgets/admin_menu_card.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_bloc.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_event.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/pages/admin_services_list_page.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/presentation/pages/technical_catalogs_page.dart';

/// Admin Home Page - Main dashboard for administrators.
///
/// This page provides access to administrative functions such as:
/// - Service catalog management (HU68, HU71, HU72)
/// - Future administrative features
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminConstants.adminHomeTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                // Menu grid
                Expanded(child: _buildMenuGrid(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AdminConstants.welcomeTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AdminConstants.welcomeSubtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: [
        AdminMenuCard(
          icon: Icons.build_circle,
          title: AdminConstants.cardServiceCatalog,
          subtitle: AdminConstants.cardServiceCatalogSubtitle,
          iconColor: Colors.blue,
          onTap: () => _navigateToServiceCatalog(context),
        ),
        AdminMenuCard(
          icon: Icons.bar_chart,
          title: AdminConstants.cardReports,
          subtitle: AdminConstants.cardReportsSubtitle,
          iconColor: Colors.grey,
          isEnabled: false,
        ),
        AdminMenuCard(
          icon: Icons.people,
          title: AdminConstants.cardUsers,
          subtitle: AdminConstants.cardUsersSubtitle,
          iconColor: Colors.grey,
          isEnabled: false,
        ),
        AdminMenuCard(
          icon: Icons.category,
          title: AdminConstants.cardTechnicalCatalogs,
          subtitle: AdminConstants.cardTechnicalCatalogsSubtitle,
          iconColor: Colors.green,
          onTap: () => _navigateToTechnicalCatalogs(context),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings, size: 60, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  AdminConstants.drawerTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AdminConstants.drawerSubtitle,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text(
              AdminConstants.menuHome,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.build_circle, color: Colors.blue),
            title: const Text(
              AdminConstants.menuServiceCatalog,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              _navigateToServiceCatalog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              AdminConstants.menuLogout,
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _navigateToServiceCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => AdminServicesBloc(
            getServicesUseCase:
                InjectorApp.resolve<GetServicesCatalogUseCase>(),
            updateServiceUseCase: InjectorApp.resolve<UpdateServiceUseCase>(),
            activateServiceUseCase:
                InjectorApp.resolve<ActivateServiceUseCase>(),
            deactivateServiceUseCase:
                InjectorApp.resolve<DeactivateServiceUseCase>(),
          )..add(LoadServices()),
          child: const AdminServicesListPage(),
        ),
      ),
    );
  }

  void _navigateToTechnicalCatalogs(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TechnicalCatalogsPage()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(AdminConstants.confirmLogoutTitle),
          content: const Text(AdminConstants.confirmLogoutMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AdminConstants.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(); // Close drawer
                context.read<LoginBloc>().add(LoginLogout());
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(AdminConstants.menuLogout),
            ),
          ],
        );
      },
    );
  }
}
