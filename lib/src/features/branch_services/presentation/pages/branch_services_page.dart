import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/constants/service_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_bloc.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_event.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/bloc/branch_services_state.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/widgets/service_toggle_card.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/widgets/service_type_chips.dart';

/// Page for managing services associated with a branch.
///
/// Shows a list of all available services from the catalog with toggle
/// switches indicating which services are associated with this branch.
class BranchServicesPage extends StatelessWidget {
  final String branchId;
  final String branchName;

  const BranchServicesPage({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BranchServicesBloc(
        catalogsRepository: InjectorApp.resolve<CatalogsRepository>(),
        branchServicesDataSource:
            InjectorApp.resolve<BranchServicesDataSource>(),
      )..add(LoadBranchServices(branchId)),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(ServiceConstants.servicesManagementTitle),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: BlocListener<BranchServicesBloc, BranchServicesState>(
          listenWhen: (prev, curr) {
            if (prev is BranchServicesLoaded && curr is BranchServicesLoaded) {
              return prev.message != curr.message && curr.message != null;
            }
            return false;
          },
          listener: (context, state) {
            if (state is BranchServicesLoaded && state.message != null) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message!),
                    backgroundColor: state.isSuccess == true
                        ? Colors.green[600]
                        : Colors.red[600],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
          child: Column(
            children: [
              // Filter chips
              ColoredBox(
                color: Colors.white,
                child: BlocBuilder<BranchServicesBloc, BranchServicesState>(
                  buildWhen: (prev, curr) =>
                      prev is! BranchServicesLoaded ||
                      curr is! BranchServicesLoaded ||
                      prev.filterType != curr.filterType,
                  builder: (context, state) {
                    String? selectedType;
                    if (state is BranchServicesLoaded) {
                      selectedType = state.filterType;
                    }
                    return ServiceTypeChips(
                      selectedType: selectedType,
                      onTypeSelected: (type) {
                        context.read<BranchServicesBloc>().add(
                          FilterServicesByType(type),
                        );
                      },
                    );
                  },
                ),
              ),

              // Search bar
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: ServiceConstants.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (query) {
                    context.read<BranchServicesBloc>().add(
                      SearchServices(query),
                    );
                  },
                ),
              ),

              // Services list
              Expanded(
                child: BlocBuilder<BranchServicesBloc, BranchServicesState>(
                  builder: (context, state) {
                    if (state is BranchServicesLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is BranchServicesError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<BranchServicesBloc>().add(
                                  LoadBranchServices(branchId),
                                );
                              },
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is BranchServicesLoaded) {
                      if (state.displayedServices.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                ServiceConstants.noServicesFound,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.displayedServices.length,
                        itemBuilder: (context, index) {
                          final service = state.displayedServices[index];
                          final isAssociated = state.associatedServiceIds
                              .contains(service.id);

                          // Find branch service for added_at date
                          final branchService = state.branchServices
                              .where((bs) => bs.id == service.id)
                              .firstOrNull;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ServiceToggleCard(
                              serviceName: service.name,
                              serviceType: service.serviceType,
                              description: service.description,
                              isAssociated: isAssociated,
                              addedAt: branchService?.addedAt,
                              onToggle: (value) {
                                context.read<BranchServicesBloc>().add(
                                  ToggleServiceAssociation(
                                    serviceId: service.id,
                                    associate: value,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
