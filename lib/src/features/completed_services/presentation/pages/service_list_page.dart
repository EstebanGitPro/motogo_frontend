import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/helpers/service_status_helpers.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/pages/service_detail_page.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';

/// Page that lists all completed services for a motorcycle.
///
/// Navigated from the "Servicios" card on [SearchMotorcyclePage].
/// Each service card can be tapped to navigate to [ServiceDetailPage].
class ServiceListPage extends StatelessWidget {
  final List<CompletedServiceEntity> services;

  const ServiceListPage({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MotorcycleConstants.servicesCardTitle),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<SearchMotorcycleBloc, SearchMotorcycleState>(
        builder: (context, state) {
          // Use live state if available, otherwise use initial services
          final liveServices = state is SearchMotorcycleLoaded
              ? state.serviceHistory
              : services;

          if (liveServices.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveServices.length,
            itemBuilder: (context, index) =>
                _buildServiceCard(context, liveServices[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            MotorcycleConstants.noServiceHistory,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              MotorcycleConstants.noServiceHistorySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    CompletedServiceEntity service,
  ) {
    final statusColor = getStatusColor(service.status);
    final statusLabel = getStatusLabel(service.status);
    final dateStr = formatServiceDate(service.requestDate);

    // Build subtitle: branch name + service count
    final parts = <String>[];
    if (service.branchName != null && service.branchName!.isNotEmpty) {
      parts.add(service.branchName!);
    }
    if (service.services.isNotEmpty) {
      parts.add(
        '${service.services.length} servicio${service.services.length > 1 ? 's' : ''}',
      );
    }
    final subtitle = parts.join(' · ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDetail(context, service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator dot
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    if (service.finalPrice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '\$${formatServicePrice(service.finalPrice!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, CompletedServiceEntity service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SearchMotorcycleBloc>(),
          child: ServiceDetailPage(service: service, canRate: false),
        ),
      ),
    );
  }
}
