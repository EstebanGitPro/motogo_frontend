import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';

/// Tab content widget displaying branch services with toggles.
///
/// Shows a list of services that can be enabled/disabled.
/// Currently uses placeholder data.
class BranchServicesTab extends StatefulWidget {
  final String branchId;

  const BranchServicesTab({super.key, required this.branchId});

  @override
  State<BranchServicesTab> createState() => _BranchServicesTabState();
}

class _BranchServicesTabState extends State<BranchServicesTab> {
  // Placeholder services data
  final Map<String, bool> _services = {
    BranchConstants.serviceBasicMaintenance: true,
    BranchConstants.serviceGeneralRepair: true,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            BranchConstants.sectionServices,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Services list
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _services.entries.map((entry) {
                final isLast = entry.key == _services.keys.last;
                return _buildServiceTile(
                  name: entry.key,
                  isEnabled: entry.value,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required String name,
    required bool isEnabled,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    _services[name] = value;
                  });
                },
                activeColor: Colors.blue[600],
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
      ],
    );
  }
}
