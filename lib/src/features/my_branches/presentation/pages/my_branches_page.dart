import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/pages/branch_detail_page.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
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
      create: (context) => MyBranchesBloc(
        InjectorApp.resolve<GetBranchesUseCase>(),
        listFranchisesUseCase: InjectorApp.resolve<ListFranchisesUseCase>(),
      )..add(LoadBranches()),
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
        title: const Text('Mis Sedes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sedes',
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.error.message,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
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

                if (state is MyBranchesLoaded) {
                  if (state.filteredBranches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.searchQuery.isNotEmpty
                                ? Icons.search_off
                                : Icons.storefront_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.searchQuery.isNotEmpty
                                ? 'No se encontraron sedes'
                                : 'Aún no tienes sedes registradas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
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
}
