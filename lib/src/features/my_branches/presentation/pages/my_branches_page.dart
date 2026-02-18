import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/pages/branch_detail_page.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_bloc.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/widgets/branch_card.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/pages/register_branch_page.dart';

/// Page displaying the list of branches for the authenticated user.
class MyBranchesPage extends StatelessWidget {
  const MyBranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectorApp.resolve<MyBranchesBloc>()..add(LoadBranches()),
      child: const _MyBranchesView(),
    );
  }
}

class _MyBranchesView extends StatefulWidget {
  const _MyBranchesView();

  @override
  State<_MyBranchesView> createState() => _MyBranchesViewState();
}

class _MyBranchesViewState extends State<_MyBranchesView>
    with WidgetsBindingObserver {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Auto-refresh when page is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MyBranchesBloc>().add(RefreshBranches());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh when app comes back to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<MyBranchesBloc>().add(RefreshBranches());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(
            child: BlocBuilder<MyBranchesBloc, MyBranchesState>(
              builder: (context, state) => _buildBranchesBody(context, state),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const RegisterBranchPage()),
          );
          if (result == true && context.mounted) {
            context.read<MyBranchesBloc>().add(RefreshBranches());
          }
        },
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
    if (state.filteredBranches.isEmpty) {
      return _buildEmptyState(state.searchQuery.isNotEmpty);
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
          return BranchCard(
            branch: branch,
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
        },
      ),
    );
  }

  Widget _buildEmptyState(bool hasSearchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.storefront_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? BranchConstants.noSearchResults
                : BranchConstants.noRegisteredBranches,
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
            label: const Text(BranchConstants.retry),
          ),
        ],
      ),
    );
  }
}
