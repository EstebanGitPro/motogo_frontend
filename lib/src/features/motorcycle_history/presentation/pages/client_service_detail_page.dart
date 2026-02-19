import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_item_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/helpers/service_status_helpers.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/widgets/rating_bottom_sheet.dart';

/// Client-side detail view for a completed service.
///
/// Read-only page showing service info (status, branch, prices, services,
/// notes) plus a rating section for FINALIZADO services.
/// Used in the motorcyclist flow: Mis Motocicletas → Historial de Servicios → tap card.
class ClientServiceDetailPage extends StatefulWidget {
  final CompletedServiceEntity service;

  const ClientServiceDetailPage({super.key, required this.service});

  @override
  State<ClientServiceDetailPage> createState() =>
      _ClientServiceDetailPageState();
}

class _ClientServiceDetailPageState extends State<ClientServiceDetailPage> {
  /// Tracks item IDs that have been rated during this session.
  final Set<String> _ratedItemIds = {};

  /// Whether any rating was submitted during this session.
  bool _hasRated = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_hasRated);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(MotorcycleConstants.serviceDetailTitle),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
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
              if (widget.service.status.toUpperCase() == 'FINALIZADO' &&
                  widget.service.services.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildRatingSection(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
            // Services performed (only show if at least one has a name)
            if (widget.service.services.any((s) => s.serviceName != null)) ...[
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
              ...widget.service.services.map(
                (item) => Padding(
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
                        child: Text(
                          item.serviceName ?? 'Servicio',
                          style: const TextStyle(fontSize: 14),
                        ),
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

  // ─── Rating Section (FINALIZADO) ─────────────────────────────────

  Widget _buildRatingSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_rate, size: 20, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  MotorcycleConstants.rateServicesTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
              widget.service.services.length,
              (i) => _buildRatingItem(widget.service.services[i], i + 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingItem(CompletedServiceItemEntity item, int index) {
    final serviceName = item.serviceName ?? 'Servicio $index';
    final effectivelyRated = item.isRated || _ratedItemIds.contains(item.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            effectivelyRated
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 18,
            color: effectivelyRated ? Colors.green[600] : Colors.grey[400],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              serviceName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          if (!effectivelyRated)
            TextButton.icon(
              onPressed: () async {
                final rated = await RatingBottomSheet.show(
                  context,
                  completedServiceId: widget.service.id,
                  itemId: item.id,
                  serviceName: serviceName,
                );
                if (mounted && rated == true) {
                  setState(() {
                    _ratedItemIds.add(item.id);
                    _hasRated = true;
                  });
                }
              },
              icon: const Icon(Icons.star_border, size: 18),
              label: const Text(MotorcycleConstants.rateItemButton),
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber[800],
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 4),
                  Text(
                    MotorcycleConstants.alreadyRatedLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── Reusable Widgets ──────────────────────────────────────────────

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
