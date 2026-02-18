import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/core/widgets/gradient_header_card.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/widgets/app_drawer.dart';
import 'package:motogo_frontend/src/core/widgets/logout_dialog.dart';
import 'package:motogo_frontend/src/features/admin_home/presentation/widgets/admin_menu_card.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/usecases/admin_service_usecases.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_bloc.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_event.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/pages/admin_services_list_page.dart';
import 'package:motogo_frontend/src/features/legal/presentation/pages/legal_page.dart';
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
      body: DecoratedBox(
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
                const GradientHeaderCard(
                  icon: Icons.admin_panel_settings,
                  title: AdminConstants.welcomeTitle,
                  subtitle: AdminConstants.welcomeSubtitle,
                ),
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
        const AdminMenuCard(
          icon: Icons.bar_chart,
          title: AdminConstants.cardReports,
          subtitle: AdminConstants.cardReportsSubtitle,
          iconColor: Colors.grey,
          isEnabled: false,
        ),
        const AdminMenuCard(
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
    return AppDrawer(
      header: const AppDrawerHeader(
        icon: Icons.admin_panel_settings,
        title: AdminConstants.drawerTitle,
        subtitle: AdminConstants.drawerSubtitle,
      ),
      menuItems: [
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
          leading: const Icon(Icons.info, color: Colors.blue),
          title: const Text(
            AdminConstants.menuAbout,
            style: TextStyle(fontSize: 16),
          ),
          onTap: () {
            Navigator.pop(context);
            _navigateToLegal(context);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            AdminConstants.menuLogout,
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
          onTap: () => showLogoutConfirmDialog(context),
        ),
      ],
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

  void _navigateToLegal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LegalPage()),
    );
  }
}
