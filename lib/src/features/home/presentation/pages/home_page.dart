import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/core/widgets/app_drawer.dart';
import 'package:motogo_frontend/src/core/widgets/shared_drawer_menu_items.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/pages/branch_detail_page.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_event.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/pages/manage_franchise_page.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_bloc.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/widgets/branch_card.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_bloc.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/pages/register_branch_page.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/pages/register_franchise_page.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/pages/search_motorcycle_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectorApp.resolve<MyBranchesBloc>()..add(LoadBranches()),
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
          create: (context) => InjectorApp.resolve<RegisterBranchBloc>(),
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
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildSearchBar(context),
            Expanded(
              child: BlocBuilder<MyBranchesBloc, MyBranchesState>(
                builder: (context, state) => _buildBranchesBody(context, state),
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

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
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
          context.read<MyBranchesBloc>().add(SearchBranches(query: value));
        },
      ),
    );
  }

  Widget _buildBranchesBody(BuildContext context, MyBranchesState state) {
    if (state is MyBranchesLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is MyBranchesError) {
      return _buildErrorState(context, state.error.message);
    }
    if (state is MyBranchesLoaded) {
      return _buildLoadedBranches(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadedBranches(BuildContext context, MyBranchesLoaded state) {
    if (state.branches.isEmpty) {
      return _buildEmptyState(context);
    }
    if (state.filteredBranches.isEmpty && state.searchQuery.isNotEmpty) {
      return _buildNoSearchResults();
    }
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MyBranchesBloc>().add(RefreshBranches());
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.filteredBranches.length,
        itemBuilder: (context, index) =>
            _buildBranchItem(context, state, index),
      ),
    );
  }

  Widget _buildBranchItem(
    BuildContext context,
    MyBranchesLoaded state,
    int index,
  ) {
    final branch = state.filteredBranches[index];
    String? franchiseName;
    if (branch.franchiseId != null) {
      franchiseName =
          state.franchiseNames[branch.franchiseId] ??
          BranchConstants.franchiseFallbackName;
    }
    return BranchCard(
      branch: branch,
      franchiseName: franchiseName,
      onFranchiseTap: branch.franchiseId != null
          ? () => _navigateToManageFranchise(context, branch.franchiseId!)
          : null,
      onTap: () async {
        final result = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute(
            builder: (context) => BranchDetailPage(branch: branch),
          ),
        );
        if (result != null && context.mounted) {
          context.read<MyBranchesBloc>().add(RefreshBranches());
        }
      },
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
          create: (context) => InjectorApp.resolve<RegisterFranchiseBloc>(),
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
    final userName = UserSessionManager.instance.currentUser?.fullName ?? '';
    return AppDrawer(
      header: AppDrawerHeader(
        icon: Icons.account_circle,
        title: MotorcycleConstants.drawerTitle,
        subtitle: userName.isNotEmpty ? userName : null,
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
        // Shared menu items (Edit Profile, Change Password, etc.)
        ...SharedDrawerMenuItems.commonItems(context),
      ],
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
              BranchConstants.welcomeTitle,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              BranchConstants.noBranchesMessage,
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
            label: const Text(CommonConstants.retry),
          ),
        ],
      ),
    );
  }
}
