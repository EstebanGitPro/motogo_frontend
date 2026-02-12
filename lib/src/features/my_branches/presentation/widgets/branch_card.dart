import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Card widget displaying a branch summary.
///
/// Shows branch image, name, address, status, and establishment type.
class BranchCard extends StatelessWidget {
  final BranchEntity branch;
  final VoidCallback? onTap;

  /// Optional label for the establishment type (from catalog).
  /// If not provided, the raw code will be displayed.
  final String? establishmentTypeLabel;

  /// Optional franchise name to display as a badge.
  final String? franchiseName;

  /// Callback when the franchise badge is tapped.
  final VoidCallback? onFranchiseTap;

  const BranchCard({
    super.key,
    required this.branch,
    this.onTap,
    this.establishmentTypeLabel,
    this.franchiseName,
    this.onFranchiseTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // Branch image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: _buildImage(),
            ),
            // Branch info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Branch name
                    Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Address with icon
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.blue[400],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            branch.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Status and type chips
                    Row(
                      children: [
                        _buildStatusChip(),
                        const SizedBox(width: 8),
                        _buildTypeChip(),
                      ],
                    ),
                    // Franchise badge (if applicable)
                    if (franchiseName != null) ...[
                      const SizedBox(height: 8),
                      _buildFranchiseBadge(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (branch.profileImageUrl != null && branch.profileImageUrl!.isNotEmpty) {
      return Image.network(
        branch.profileImageUrl!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: Icon(Icons.storefront, size: 40, color: Colors.grey[400]),
    );
  }

  Widget _buildStatusChip() {
    final isActive = branch.status == BranchStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: Text(
        isActive
            ? BranchConstants.statusActive
            : BranchConstants.statusInactive,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    // Use provided label or translate the raw backend code
    final displayText =
        establishmentTypeLabel ?? _mapTypeToLabel(branch.establishmentType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!, width: 1),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 11,
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

  Widget _buildFranchiseBadge() {
    return GestureDetector(
      onTap: onFranchiseTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange[300]!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store, size: 14, color: Colors.orange[700]),
            const SizedBox(width: 6),
            Text(
              franchiseName!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: Colors.orange[700]),
          ],
        ),
      ),
    );
  }
}
