import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/features/admin_services/domain/entities/admin_service_entity.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_bloc.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_event.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_state.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/pages/edit_service_page.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/widgets/admin_service_card.dart';

/// Page for listing and managing the global service catalog.
///
/// Allows administrators to:
/// - View all services in the catalog
/// - Search and filter by type
/// - Activate/Deactivate services (HU71, HU72)
/// - Navigate to edit a service (HU68)
class AdminServicesListPage extends StatefulWidget {
  const AdminServicesListPage({super.key});

  @override
  State<AdminServicesListPage> createState() => _AdminServicesListPageState();
}

class _AdminServicesListPageState extends State<AdminServicesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedType;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AdminConstants.serviceCatalogTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocConsumer<AdminServicesBloc, AdminServicesState>(
          listener: (context, state) {
            if (state is AdminServicesUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AdminServicesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is AdminServicesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminServicesError) {
              return _buildErrorState(context, state.error.message);
            }

            List<AdminServiceEntity> filteredServices = [];
            List<String> availableTypes = [];
            String? updatingServiceId;

            if (state is AdminServicesLoaded) {
              filteredServices = state.filteredServices;
              availableTypes = state.availableTypes;
            } else if (state is AdminServicesUpdating) {
              filteredServices = state.filteredServices;
              updatingServiceId = state.updatingServiceId;
            } else if (state is AdminServicesUpdateSuccess) {
              filteredServices = state.previousState.filteredServices;
              availableTypes = state.previousState.availableTypes;
            }

            return Column(
              children: [
                // Search and filter section
                _buildSearchAndFilter(context, availableTypes),
                // Services list
                Expanded(
                  child: filteredServices.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            context.read<AdminServicesBloc>().add(
                              RefreshServices(),
                            );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            itemCount: filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = filteredServices[index];
                              return AdminServiceCard(
                                name: service.name,
                                serviceType: service.serviceType,
                                description: service.description,
                                isActive: service.isActive,
                                isUpdating: updatingServiceId == service.id,
                                onEdit: () => _navigateToEdit(context, service),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, List<String> types) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AdminConstants.searchServicesPlaceholder,
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
              context.read<AdminServicesBloc>().add(
                SearchServices(query: value, typeFilter: _selectedType),
              );
            },
          ),
          const SizedBox(height: 12),
          // Type filter dropdown
          DropdownButtonFormField<String?>(
            initialValue: _selectedType,
            decoration: InputDecoration(
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
            hint: const Text(AdminConstants.filterAllTypes),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text(AdminConstants.filterAllTypes),
              ),
              ...types.map(
                (type) => DropdownMenuItem(value: type, child: Text(type)),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
              context.read<AdminServicesBloc>().add(
                SearchServices(
                  query: _searchController.text,
                  typeFilter: value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            AdminConstants.noServicesFound,
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
              context.read<AdminServicesBloc>().add(LoadServices());
            },
            icon: const Icon(Icons.refresh),
            label: const Text(AdminConstants.retryButton),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit(BuildContext context, AdminServiceEntity service) async {
    final bloc = context.read<AdminServicesBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditServicePage(service: service),
      ),
    );

    if (result == true && mounted) {
      bloc.add(RefreshServices());
    }
  }
}
