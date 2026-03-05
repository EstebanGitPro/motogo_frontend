import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_item_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/helpers/service_status_helpers.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/widgets/rating_bottom_sheet.dart';

/// ─── Status Header ─────────────────────────────────────────────────
///
/// Displays the current status badge and the request date.
class ServiceStatusHeader extends StatelessWidget {
  final String status;
  final DateTime requestDate;

  const ServiceStatusHeader({
    super.key,
    required this.status,
    required this.requestDate,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = getStatusLabel(status);
    final statusColor = getStatusColor(status);
    final dateStr = formatServiceDate(requestDate);

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
}

/// ─── Detail Row ────────────────────────────────────────────────────
///
/// A single icon + label + value row used inside [ServiceInfoSection].
class ServiceDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const ServiceDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
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

/// ─── Info Section ──────────────────────────────────────────────────
///
/// Card with service details: branch, prices, diagnostic, services list,
/// notes. If [onEdit] is provided, an edit icon is shown in the top-right
/// corner (for the representative side).
class ServiceInfoSection extends StatelessWidget {
  final CompletedServiceEntity service;

  /// If non-null, shows an edit button that triggers this callback.
  /// Typically only used by the representative / admin side.
  final VoidCallback? onEdit;

  const ServiceInfoSection({super.key, required this.service, this.onEdit});

  /// Whether the service is in an editable state (representative side).
  bool get _isEditable {
    if (onEdit == null) return false;
    final status = service.status.toUpperCase();
    return status == 'PENDIENTE' || status == 'EN_PROCESO';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isEditable) ...[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.blue[700]),
                  tooltip: MotorcycleConstants.editServiceTitle,
                  onPressed: onEdit,
                ),
              ),
            ],
            // Branch name
            if (service.branchName != null &&
                service.branchName!.isNotEmpty) ...[
              ServiceDetailRow(
                icon: Icons.store,
                label: MotorcycleConstants.branchLabel,
                value: service.branchName!,
              ),
              const SizedBox(height: 14),
            ],
            // Final price
            if (service.finalPrice != null) ...[
              ServiceDetailRow(
                icon: Icons.payments,
                label: MotorcycleConstants.finalPriceLabel,
                value: '\$${formatServicePrice(service.finalPrice!)}',
                valueColor: Colors.green[700],
              ),
              const SizedBox(height: 14),
            ],
            // Quoted price
            if (service.quotedPrice != null) ...[
              ServiceDetailRow(
                icon: Icons.request_quote,
                label: MotorcycleConstants.quotedPriceLabel,
                value: '\$${formatServicePrice(service.quotedPrice!)}',
              ),
              const SizedBox(height: 14),
            ],
            // Diagnostic ref
            if (service.diagnosticId != null) ...[
              ServiceDetailRow(
                icon: Icons.assignment,
                label: MotorcycleConstants.diagnosticRefLabel,
                value: service.diagnosticId!.substring(0, 8),
                valueColor: Colors.orange[700],
              ),
              const SizedBox(height: 14),
            ],
            // Services performed (only show if at least one has a name)
            if (service.services.any((s) => s.serviceName != null)) ...[
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
              ...service.services.map(
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
            if (service.representativeNotes != null &&
                service.representativeNotes!.trim().isNotEmpty) ...[
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
                      service.representativeNotes!,
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
}

/// ─── Rating Item ───────────────────────────────────────────────────
///
/// A single rating row inside [ServiceRatingSection].
class ServiceRatingItem extends StatelessWidget {
  final CompletedServiceItemEntity item;
  final int index;

  /// Whether this item should appear as rated (overrides [item.isRated]).
  final bool effectivelyRated;

  /// Called when the user taps "Calificar". Must show the rating UI
  /// and call [onRateSuccess] when a rating is submitted.
  final VoidCallback? onRate;

  const ServiceRatingItem({
    super.key,
    required this.item,
    required this.index,
    required this.effectivelyRated,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final serviceName = item.serviceName ?? 'Servicio $index';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (effectivelyRated &&
                    item.isRated &&
                    item.rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < item.rating! ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!effectivelyRated)
            TextButton.icon(
              onPressed: onRate,
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
}

/// ─── Rating Section ────────────────────────────────────────────────
///
/// Card containing all [ServiceRatingItem]s for a FINALIZADO service.
///
/// [ratedItemIds] allows the parent to override the rated status of items
/// that were rated during the current session (before a backend refresh).
///
/// [onItemRated] is called with the item ID after a successful rating,
/// so the parent can update its local state.
class ServiceRatingSection extends StatelessWidget {
  final String completedServiceId;
  final List<CompletedServiceItemEntity> items;

  /// Set of item IDs that have been rated during this session.
  final Set<String> ratedItemIds;

  /// Called after a rating is successfully submitted.
  final ValueChanged<String>? onItemRated;

  const ServiceRatingSection({
    super.key,
    required this.completedServiceId,
    required this.items,
    this.ratedItemIds = const {},
    this.onItemRated,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

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
            ...List.generate(items.length, (i) {
              final item = items[i];
              final effectivelyRated =
                  item.isRated || ratedItemIds.contains(item.id);

              return ServiceRatingItem(
                item: item,
                index: i + 1,
                effectivelyRated: effectivelyRated,
                onRate: effectivelyRated
                    ? null
                    : () async {
                        final rated = await RatingBottomSheet.show(
                          context,
                          completedServiceId: completedServiceId,
                          itemId: item.id,
                          serviceName: item.serviceName ?? 'Servicio ${i + 1}',
                        );
                        if (rated == true) {
                          onItemRated?.call(item.id);
                        }
                      },
              );
            }),
          ],
        ),
      ),
    );
  }
}
