import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/presentation/bloc/motorcycle_history_bloc.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/presentation/pages/client_service_detail_page.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Page displaying the service history for a motorcycle.
///
/// Shows completed services fetched from the backend via
/// GET /motorcycles/:id/completed-services.
class MotorcycleHistoryPage extends StatelessWidget {
  final MotorcycleEntity motorcycle;

  const MotorcycleHistoryPage({super.key, required this.motorcycle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MotorcycleConstants.motorcycleHistoryTitle),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildMotorcycleHeader(),
          const Divider(height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildMotorcycleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.two_wheeler, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motorcycle.licensePlate.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildSubtitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (motorcycle.year != null) parts.add('Año: ${motorcycle.year}');
    if (motorcycle.currentMileage != null) {
      parts.add('${motorcycle.currentMileage} km');
    }
    return parts.isEmpty ? '' : parts.join(' | ');
  }

  Widget _buildBody() {
    return BlocBuilder<MotorcycleHistoryBloc, MotorcycleHistoryState>(
      builder: (context, state) {
        if (state is MotorcycleHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MotorcycleHistoryError) {
          return _buildErrorState(context, state.message);
        }

        if (state is MotorcycleHistoryLoaded) {
          if (state.isEmpty) {
            return _buildEmptyState();
          }
          return _buildServiceList(state.services);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (motorcycle.id != null) {
                  context.read<MotorcycleHistoryBloc>().add(
                    LoadMotorcycleHistory(motorcycle.id!),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text(CommonConstants.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              MotorcycleConstants.noServiceHistory,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              MotorcycleConstants.noServiceHistorySubtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceList(List<CompletedServiceEntity> services) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _ServiceHistoryCard(
          service: services[index],
          motorcycleId: motorcycle.id!,
        );
      },
    );
  }
}

class _ServiceHistoryCard extends StatelessWidget {
  final CompletedServiceEntity service;
  final String motorcycleId;

  const _ServiceHistoryCard({
    required this.service,
    required this.motorcycleId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: service name + status chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      service.services.isNotEmpty
                          ? service.services
                                .map((s) => s.serviceName ?? 'Servicio')
                                .join(', ')
                          : 'Servicio',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(),
                ],
              ),

              // Branch name (sede)
              if (service.branchName != null &&
                  service.branchName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.store, size: 15, color: Colors.blue[400]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        service.branchName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 15, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('dd MMM yyyy', 'es').format(service.requestDate),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price section
              _buildPriceSection(),

              // Representative notes
              if (service.representativeNotes != null &&
                  service.representativeNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 18, color: Colors.blue[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MotorcycleConstants.representativeNotesLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            service.representativeNotes!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // Diagnostic reference
              if (service.diagnosticId != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.link, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      '${MotorcycleConstants.diagnosticRefLabel}: ${service.diagnosticId!.substring(0, service.diagnosticId!.length.clamp(0, 12))}...',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(BuildContext context) async {
    final rated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ClientServiceDetailPage(service: service),
      ),
    );
    if (rated == true && context.mounted) {
      context.read<MotorcycleHistoryBloc>().add(
        LoadMotorcycleHistory(motorcycleId),
      );
    }
  }

  Widget _buildStatusChip() {
    final (label, color) = switch (service.status) {
      'FINALIZADO' => (MotorcycleConstants.statusCompleted, Colors.green),
      'EN_PROCESO' => (MotorcycleConstants.statusInProgress, Colors.orange),
      'SOLICITADO' => (MotorcycleConstants.statusRequested, Colors.blue),
      _ => (service.status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color[700] ?? color,
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Row(
      children: [
        // Quoted price
        Expanded(
          child: _buildPriceItem(
            label: MotorcycleConstants.quotedPriceLabel,
            value: service.quotedPrice != null
                ? formatter.format(service.quotedPrice)
                : '—',
            icon: Icons.request_quote,
            color: Colors.blue[600]!,
          ),
        ),
        const SizedBox(width: 12),
        // Final price
        Expanded(
          child: _buildPriceItem(
            label: MotorcycleConstants.finalPriceLabel,
            value: service.finalPrice != null
                ? formatter.format(service.finalPrice)
                : '—',
            icon: Icons.payments,
            color: Colors.green[600]!,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
