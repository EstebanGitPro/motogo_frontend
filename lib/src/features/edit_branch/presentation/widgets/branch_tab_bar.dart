import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';

/// Tab bar widget for branch detail navigation.
///
/// Displays 4 navigation options: Services, Schedule, Location, Edit.
class BranchTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const BranchTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab(
            icon: Icons.build_outlined,
            label: BranchConstants.tabServices,
            index: 0,
          ),
          _buildTab(
            icon: Icons.schedule_outlined,
            label: BranchConstants.tabSchedule,
            index: 1,
          ),
          _buildTab(
            icon: Icons.location_on_outlined,
            label: BranchConstants.tabLocation,
            index: 2,
          ),
          _buildTab(
            icon: Icons.edit_outlined,
            label: BranchConstants.tabEdit,
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? Colors.blue[700] : Colors.grey[600];

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
