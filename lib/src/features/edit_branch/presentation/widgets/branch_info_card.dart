import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Card widget displaying detailed branch information.
///
/// Shows name, status, establishment type, brands, and address.
class BranchInfoCard extends StatelessWidget {
  final BranchEntity branch;

  /// Optional label for the establishment type (from catalog).
  final String? establishmentTypeLabel;

  /// Map of brand IDs to names for display.
  /// If provided, brand chips will show names instead of IDs.
  final Map<String, String>? brandNamesMap;

  /// Whether brands are currently being loaded.
  final bool isLoadingBrands;

  const BranchInfoCard({
    super.key,
    required this.branch,
    this.establishmentTypeLabel,
    this.brandNamesMap,
    this.isLoadingBrands = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and status row
          Row(
            children: [
              Expanded(
                child: Text(
                  branch.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 12),

          // Type and brands chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(),
              if (isLoadingBrands)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                ...branch.brands.map((brandId) => _buildBrandChip(brandId)),
            ],
          ),
          const SizedBox(height: 12),

          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.blue[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  branch.address,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final isActive = branch.status == BranchStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isActive ? Colors.green[600] : Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            isActive
                ? BranchConstants.statusActive
                : BranchConstants.statusInactive,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green[700] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip() {
    final displayText =
        establishmentTypeLabel ?? _mapTypeToLabel(branch.establishmentType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  /// Maps backend establishment type codes to Spanish display labels.
  static String _mapTypeToLabel(String type) {
    switch (type.toUpperCase()) {
      case 'WORKSHOP':
        return 'Taller';
      case 'STORE':
        return 'Tienda';
      case 'WORKSHOP_STORE':
        return 'Taller y Tienda';
      default:
        return type;
    }
  }

  Widget _buildBrandChip(String brandId) {
    // Use resolved name if available, otherwise show ID
    final displayText = brandNamesMap?[brandId] ?? brandId;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}
