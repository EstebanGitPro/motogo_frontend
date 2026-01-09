import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/widgets/branch_info_card.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/widgets/branch_services_tab.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/widgets/branch_tab_bar.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Page displaying detailed information about a branch.
///
/// Shows branch info, image, and provides navigation to different
/// management sections: Services, Schedule, Location, and Edit.
class BranchDetailPage extends StatefulWidget {
  final BranchEntity branch;

  const BranchDetailPage({super.key, required this.branch});

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Sede ${widget.branch.name}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Hero image
          _buildHeroImage(),

          // Branch info card
          BranchInfoCard(branch: widget.branch),

          // Tab bar
          BranchTabBar(
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),

          // Tab content
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(color: Colors.grey[300]),
      child:
          widget.branch.profileImageUrl != null &&
              widget.branch.profileImageUrl!.isNotEmpty
          ? Image.network(
              widget.branch.profileImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              widget.branch.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return BranchServicesTab(branchId: widget.branch.id ?? '');
      case 1:
        return _buildPlaceholderTab(BranchConstants.tabSchedule);
      case 2:
        return _buildPlaceholderTab(BranchConstants.tabLocation);
      case 3:
        return _buildPlaceholderTab(BranchConstants.tabEdit);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPlaceholderTab(String tabName) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            tabName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            BranchConstants.comingSoon,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
