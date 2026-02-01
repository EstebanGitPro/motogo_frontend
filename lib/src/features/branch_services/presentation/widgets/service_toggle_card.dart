import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motogo_frontend/src/core/constants/service_constants.dart';

/// Widget displaying a service card with toggle switch.
///
/// Shows service name, type badge, description, last updated date,
/// and a toggle to associate/dissociate the service from a branch.
class ServiceToggleCard extends StatelessWidget {
  final String serviceName;
  final String serviceType;
  final String description;
  final bool isAssociated;
  final DateTime? addedAt;
  final ValueChanged<bool> onToggle;

  const ServiceToggleCard({
    super.key,
    required this.serviceName,
    required this.serviceType,
    required this.description,
    required this.isAssociated,
    this.addedAt,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(serviceType).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      serviceType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getTypeColor(serviceType),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Added at timestamp (only if associated)
                  if (isAssociated && addedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${ServiceConstants.lastUpdated} ${_formatDate(addedAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Toggle switch
            Switch(
              value: isAssociated,
              onChanged: onToggle,
              activeThumbColor: Colors.blue[600],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'mantenimiento':
        return const Color(0xFF3B82F6); // Blue
      case 'reparación':
        return const Color(0xFFF59E0B); // Orange
      case 'llantas':
        return const Color(0xFF10B981); // Green
      case 'diagnóstico':
        return const Color(0xFF8B5CF6); // Purple
      case 'estética':
        return const Color(0xFFEC4899); // Pink
      case 'accesorios':
        return const Color(0xFF06B6D4); // Cyan
      case 'eléctrico':
        return const Color(0xFFEAB308); // Yellow
      case 'legal':
        return const Color(0xFF6B7280); // Gray
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'es');
    return formatter.format(date);
  }
}
