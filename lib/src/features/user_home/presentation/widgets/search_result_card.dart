import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';

/// Compact card displayed in the search results overlay.
///
/// Shows branch name, address, distance, and type icon.
/// Tapping selects the branch and centers the map on it.
class SearchResultCard extends StatelessWidget {
  final BranchMarkerEntity branch;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.branch,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWorkshopType = branch.isWorkshop || branch.isWorkshopStore;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            _buildIcon(isWorkshopType),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo()),
            if (branch.distanceKm != null) _buildDistance(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isWorkshopType) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isWorkshopType ? Colors.orange[50] : Colors.green[50],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isWorkshopType ? Icons.build : Icons.store,
        size: 20,
        color: isWorkshopType ? Colors.orange[600] : Colors.green[600],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          branch.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (branch.address != null)
          Text(
            branch.address!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        Row(
          children: [
            Text(
              branch.displayTypeLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: (branch.isWorkshop || branch.isWorkshopStore)
                    ? Colors.orange[700]
                    : Colors.green[700],
              ),
            ),
            if (branch.rating != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.star, size: 14, color: Colors.amber[600]),
              const SizedBox(width: 2),
              Text(
                branch.rating!.toStringAsFixed(1),
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDistance() {
    return Text(
      branch.formattedDistance,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.blue[700],
      ),
    );
  }
}
