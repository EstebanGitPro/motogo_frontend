import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';

/// Card widget showing details of a selected branch on the map.
///
/// Displays the branch name, type, address, rating, distance,
/// and action buttons for navigating to details or getting directions.
class BranchCard extends StatelessWidget {
  final BranchMarkerEntity branch;
  final VoidCallback onSeeMore;
  final VoidCallback onNavigate;

  const BranchCard({
    super.key,
    required this.branch,
    required this.onSeeMore,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isWorkshopType = branch.isWorkshop || branch.isWorkshopStore;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isWorkshopType),
            const SizedBox(height: 12),
            _buildTypeAndDistance(isWorkshopType),
            const SizedBox(height: 8),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWorkshopType) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isWorkshopType ? Colors.orange[50] : Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isWorkshopType ? Icons.build : Icons.store,
            color: isWorkshopType ? Colors.orange[600] : Colors.green[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branch.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (branch.address != null)
                Text(
                  branch.address!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        if (branch.rating != null)
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              Text(branch.rating!.toStringAsFixed(1)),
            ],
          ),
      ],
    );
  }

  Widget _buildTypeAndDistance(bool isWorkshopType) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isWorkshopType ? Colors.orange[100] : Colors.green[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            branch.displayTypeLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isWorkshopType ? Colors.orange[800] : Colors.green[800],
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (branch.distanceKm != null)
          Text(
            '${branch.distanceKm!.toStringAsFixed(1)} km',
            style: TextStyle(color: Colors.grey[600]),
          ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onSeeMore,
          child: const Text(CommonConstants.seeMore),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: OutlinedButton.icon(
            onPressed: onNavigate,
            icon: const Icon(Icons.directions, size: 18),
            label: const Text(
              CommonConstants.howToGetThere,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
