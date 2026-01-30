import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/pages/change_password_page.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/pages/branch_detail_page.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/pages/edit_profile_page.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_bloc.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/widgets/branch_card.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_bloc.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/pages/register_branch_page.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/pages/register_franchise_page.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_event.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/pages/manage_franchise_page.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/usecases/delete_person_usecase.dart';
import 'package:motogo_frontend/src/core/constants/person_constants.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/pages/search_motorcycle_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyBranchesBloc(
        listFranchisesUseCase: InjectorApp.resolve<ListFranchisesUseCase>(),
      )..add(LoadBranches()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToRegisterBranch(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => RegisterBranchBloc(),
          child: const RegisterBranchPage(),
        ),
      ),
    );

    // Refresh branches if a new one was created
    if (result == true && context.mounted) {
      context.read<MyBranchesBloc>().add(RefreshBranches());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(BranchConstants.myBranchesTitle),
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
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: BranchConstants.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  context.read<MyBranchesBloc>().add(
                    SearchBranches(query: value),
                  );
                },
              ),
            ),
            // Branches list
            Expanded(
              child: BlocBuilder<MyBranchesBloc, MyBranchesState>(
                builder: (context, state) {
                  if (state is MyBranchesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MyBranchesError) {
                    return _buildErrorState(context, state.error.message);
                  }

                  if (state is MyBranchesLoaded) {
                    if (state.branches.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    if (state.filteredBranches.isEmpty &&
                        state.searchQuery.isNotEmpty) {
                      return _buildNoSearchResults();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<MyBranchesBloc>().add(RefreshBranches());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: state.filteredBranches.length,
                        itemBuilder: (context, index) {
                          final branch = state.filteredBranches[index];
                          // Get franchise name from the map if exists, fallback to "Franquicia" if has ID
                          String? franchiseName;
                          if (branch.franchiseId != null) {
                            franchiseName =
                                state.franchiseNames[branch.franchiseId] ??
                                'Franquicia';
                          }
                          return BranchCard(
                            branch: branch,
                            franchiseName: franchiseName,
                            onFranchiseTap: branch.franchiseId != null
                                ? () => _navigateToManageFranchise(
                                    context,
                                    branch.franchiseId!,
                                  )
                                : null,
                            onTap: () async {
                              final result = await Navigator.push<dynamic>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BranchDetailPage(branch: branch),
                                ),
                              );
                              if (result != null && context.mounted) {
                                context.read<MyBranchesBloc>().add(
                                  RefreshBranches(),
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    final parentContext = context; // Capture parent context
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.storefront,
                  color: Colors.blue[600],
                  size: 32,
                ),
                title: const Text(
                  BranchConstants.newBranchOption,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _navigateToRegisterBranch(parentContext);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.store, color: Colors.blue[600], size: 32),
                title: const Text(
                  BranchConstants.newFranchiseOption,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _navigateToRegisterFranchise(parentContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRegisterFranchise(BuildContext context) async {
    // Get branches without franchise from the current loaded state
    final myBranchesState = context.read<MyBranchesBloc>().state;
    List<BranchEntity> availableBranches = [];

    if (myBranchesState is MyBranchesLoaded) {
      availableBranches = myBranchesState.branches
          .where(
            (branch) =>
                branch.id != null &&
                !myBranchesState.branchesWithFranchise.contains(branch.id),
          )
          .toList();
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => RegisterFranchiseBloc(),
          child: RegisterFranchisePage(availableBranches: availableBranches),
        ),
      ),
    );

    // Refresh branches if a new franchise was created
    if (result == true && context.mounted) {
      context.read<MyBranchesBloc>().add(RefreshBranches());
    }
  }

  void _navigateToManageFranchise(
    BuildContext context,
    String franchiseId,
  ) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) =>
              ManageFranchiseBloc()..add(LoadFranchise(franchiseId)),
          child: ManageFranchisePage(franchiseId: franchiseId),
        ),
      ),
    );

    // Refresh branches if any changes were made
    if (result == true && context.mounted) {
      context.read<MyBranchesBloc>().add(RefreshBranches());
    }
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
                Icon(Icons.account_circle, size: 60, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Menú Principal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Inicio', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.blue),
            title: const Text(
              MotorcycleConstants.menuSearchByPlate,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchMotorcyclePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Editar Perfil', style: TextStyle(fontSize: 16)),
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
            leading: const Icon(Icons.lock, color: Colors.blue),
            title: const Text(
              'Cambiar Contraseña',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => ChangePasswordBloc(),
                    child: const ChangePasswordPage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              PersonConstants.deleteAccountMenuTitle,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.blue),
            title: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text('Acerca de', style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_outlined,
                size: 80,
                color: Colors.blue[400],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¡Bienvenido!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Aún no tienes sedes registradas.\nCrea tu primera sede para empezar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToRegisterBranch(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                BranchConstants.createFirstBranchButton,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            BranchConstants.noSearchResults,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<MyBranchesBloc>().add(LoadBranches());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final confirmController = TextEditingController();
    bool isConfirmValid = false;
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      PersonConstants.deleteAccountTitle,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    PersonConstants.deleteAccountWarning,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    PersonConstants.deleteAccountConfirmPrompt,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    enabled: !isDeleting,
                    decoration: InputDecoration(
                      hintText: PersonConstants.deleteAccountConfirmWord,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        isConfirmValid =
                            value.toLowerCase().trim() ==
                            PersonConstants.deleteAccountConfirmWord;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: (!isConfirmValid || isDeleting)
                      ? null
                      : () async {
                          setDialogState(() {
                            isDeleting = true;
                          });

                          final deleteUseCase =
                              InjectorApp.resolve<DeletePersonUseCase>();
                          final result = await deleteUseCase();

                          result.fold(
                            (error) {
                              setDialogState(() {
                                isDeleting = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            (message) {
                              Navigator.pop(dialogContext);
                              // Show success message from backend
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Clear session and redirect to login
                              context.read<LoginBloc>().add(LoginLogout());
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            },
                          );
                        },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(PersonConstants.deleteAccountButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
              title: const Text('Cerrar Sesión'),
              content: const Text(
                '¿Estás seguro de que quieres cerrar sesión?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<LoginBloc>().add(LoginLogout());
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cerrar Sesión'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
