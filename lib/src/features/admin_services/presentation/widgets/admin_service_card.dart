import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/admin_constants.dart';
import 'package:motogo_frontend/src/core/constants/service_constants.dart';

/// Card widget for displaying a service in the admin catalog.
///
/// Shows service info with an edit button. Toggle functionality
/// is available inside the edit page.
class AdminServiceCard extends StatelessWidget {
  final String name;
  final String serviceType;
  final String? description;
  final bool isActive;
  final bool isUpdating;
  final VoidCallback? onEdit;

  const AdminServiceCard({
    super.key,
    required this.name,
    required this.serviceType,
    this.description,
    required this.isActive,
    this.isUpdating = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? Colors.green[100]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isUpdating ? null : onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ServiceConstants.getServiceTypeColor(
                    serviceType,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: ServiceConstants.getServiceTypeColor(serviceType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Name, type, and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ServiceConstants.getServiceTypeColor(
                              serviceType,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            serviceType,
                            style: TextStyle(
                              fontSize: 11,
                              color: ServiceConstants.getServiceTypeColor(
                                serviceType,
                              ),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive
                              ? AdminConstants.serviceActive
                              : AdminConstants.serviceInactive,
                          style: TextStyle(
                            fontSize: 11,
                            color: isActive ? Colors.green[700] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Edit icon or loading
              const SizedBox(width: 8),
              if (isUpdating)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (serviceType.toLowerCase()) {
      case 'mantenimiento':
        return Icons.build;
      case 'reparación':
      case 'reparacion':
        return Icons.handyman;
      case 'diagnóstico':
      case 'diagnostico':
        return Icons.search;
      case 'estética':
      case 'estetica':
        return Icons.auto_awesome;
      default:
        return Icons.miscellaneous_services;
    }
  }
}
