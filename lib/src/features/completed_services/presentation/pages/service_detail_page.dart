import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/status_transition_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/helpers/service_status_helpers.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';

/// Full-page detail view for a completed service.
///
/// Shows current status, service info, action buttons based on status,
/// and the transition history timeline.
class ServiceDetailPage extends StatefulWidget {
  final CompletedServiceEntity service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch transition history when entering the page
    context.read<SearchMotorcycleBloc>().add(
      FetchServiceTransitions(serviceId: widget.service.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchMotorcycleBloc, SearchMotorcycleState>(
      listenWhen: (prev, curr) {
        if (prev is SearchMotorcycleLoaded && curr is SearchMotorcycleLoaded) {
          return prev.statusUpdateMessage != curr.statusUpdateMessage ||
              prev.statusUpdateError != curr.statusUpdateError ||
              prev.deleteServiceMessage != curr.deleteServiceMessage ||
              prev.deleteServiceError != curr.deleteServiceError;
        }
        return false;
      },
      listener: (context, state) {
        if (state is SearchMotorcycleLoaded) {
          // Status update feedback
          if (state.statusUpdateMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.statusUpdateMessage!),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.statusUpdateError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.statusUpdateError!),
                backgroundColor: Colors.red,
              ),
            );
          }
          // Delete service feedback
          if (state.deleteServiceMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.deleteServiceMessage!),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.deleteServiceError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.deleteServiceError!),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final isUpdating =
            state is SearchMotorcycleLoaded && state.isUpdatingStatus;
        final isDeleting =
            state is SearchMotorcycleLoaded && state.isDeletingService;
        final transitions = state is SearchMotorcycleLoaded
            ? state.serviceTransitions
            : <StatusTransitionEntity>[];

        return Scaffold(
          appBar: AppBar(
            title: const Text(MotorcycleConstants.serviceDetailTitle),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(),
                const SizedBox(height: 24),
                _buildInfoSection(),
                const SizedBox(height: 24),
                _buildActionButtons(isUpdating),
                const SizedBox(height: 16),
                _buildDeleteButton(isDeleting),
                if (transitions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildTransitionTimeline(transitions),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Status Header ─────────────────────────────────────────────────

  Widget _buildStatusHeader() {
    final statusLabel = getStatusLabel(widget.service.status);
    final statusColor = getStatusColor(widget.service.status);
    final dateStr = formatServiceDate(widget.service.requestDate);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estado Actual',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Fecha Solicitud',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Info Section ──────────────────────────────────────────────────

  Widget _buildInfoSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch name
            if (widget.service.branchName != null &&
                widget.service.branchName!.isNotEmpty) ...[
              _buildDetailRow(
                Icons.store,
                MotorcycleConstants.branchLabel,
                widget.service.branchName!,
              ),
              const SizedBox(height: 14),
            ],
            // Final price
            if (widget.service.finalPrice != null) ...[
              _buildDetailRow(
                Icons.payments,
                MotorcycleConstants.finalPriceLabel,
                '\$${formatServicePrice(widget.service.finalPrice!)}',
                valueColor: Colors.green[700],
              ),
              const SizedBox(height: 14),
            ],
            // Quoted price
            if (widget.service.quotedPrice != null) ...[
              _buildDetailRow(
                Icons.request_quote,
                MotorcycleConstants.quotedPriceLabel,
                '\$${formatServicePrice(widget.service.quotedPrice!)}',
              ),
              const SizedBox(height: 14),
            ],
            // Diagnostic ref
            if (widget.service.diagnosticId != null) ...[
              _buildDetailRow(
                Icons.assignment,
                MotorcycleConstants.diagnosticRefLabel,
                widget.service.diagnosticId!.substring(0, 8),
                valueColor: Colors.orange[700],
              ),
              const SizedBox(height: 14),
            ],
            // Services performed
            if (widget.service.serviceNames.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.build_outlined, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    MotorcycleConstants.servicesPerformedLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...widget.service.serviceNames.map(
                (name) => Padding(
                  padding: const EdgeInsets.only(left: 26, bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(name, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // Notes
            if (widget.service.representativeNotes != null &&
                widget.service.representativeNotes!.trim().isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MotorcycleConstants.representativeNotesLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.service.representativeNotes!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Action Buttons ────────────────────────────────────────────────

  Widget _buildActionButtons(bool isUpdating) {
    final status = widget.service.status.toUpperCase();

    // Terminal states — no actions
    if (status == 'FINALIZADO' || status == 'CANCELADO') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (status == 'PENDIENTE') ...[
          _buildPrimaryActionButton(
            isUpdating: isUpdating,
            targetStatus: 'EN_PROCESO',
            icon: Icons.play_arrow,
            label: MotorcycleConstants.startServiceButton,
            color: Colors.blue,
          ),
          const SizedBox(height: 10),
          _buildCancelButton(isUpdating),
        ],
        if (status == 'EN_PROCESO') ...[
          _buildPrimaryActionButton(
            isUpdating: isUpdating,
            targetStatus: 'FINALIZADO',
            icon: Icons.check_circle,
            label: MotorcycleConstants.finalizeServiceButton,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          _buildCancelButton(isUpdating),
        ],
      ],
    );
  }

  // ─── Transition History Timeline ───────────────────────────────────

  Widget _buildTransitionTimeline(List<StatusTransitionEntity> transitions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MotorcycleConstants.transitionHistoryTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        ...transitions.asMap().entries.map((entry) {
          final index = entry.key;
          final transition = entry.value;
          final isLast = index == transitions.length - 1;
          final color = getStatusColor(transition.newStatus);
          final dateStr = formatServiceDateTime(transition.createdAt);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline connector
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(width: 2, color: Colors.grey[300]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (transition.previousStatus != null) ...[
                              Text(
                                getStatusLabel(transition.previousStatus!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            Text(
                              getStatusLabel(transition.newStatus),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────

  void _updateStatus(String newStatus) {
    context.read<SearchMotorcycleBloc>().add(
      UpdateServiceStatus(
        serviceId: widget.service.id,
        motorcycleId: widget.service.motorcycleId,
        newStatus: newStatus,
      ),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(MotorcycleConstants.cancelServiceButton),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este servicio? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateStatus('CANCELADO');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(MotorcycleConstants.deleteServiceButton),
        content: const Text(MotorcycleConstants.deleteServiceConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<SearchMotorcycleBloc>().add(
                DeleteCompletedService(
                  serviceId: widget.service.id,
                  motorcycleId: widget.service.motorcycleId,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }

  // ─── Reusable Widgets ──────────────────────────────────────────────

  Widget _buildPrimaryActionButton({
    required bool isUpdating,
    required String targetStatus,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isUpdating ? null : () => _updateStatus(targetStatus),
        icon: isUpdating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(bool isUpdating) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isUpdating ? null : () => _confirmCancel(),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text(MotorcycleConstants.cancelServiceButton),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(bool isDeleting) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isDeleting ? null : () => _confirmDelete(),
        icon: isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : const Icon(Icons.delete_outline),
        label: Text(
          isDeleting
              ? 'Eliminando...'
              : MotorcycleConstants.deleteServiceButton,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[700]!),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
