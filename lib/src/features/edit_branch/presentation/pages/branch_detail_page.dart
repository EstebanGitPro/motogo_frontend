import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/widgets/branch_schedule_tab.dart';
import 'package:motogo_frontend/src/features/delete_branch/domain/usecases/delete_branch_usecase.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/pages/edit_branch_page.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/widgets/branch_info_card.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/widgets/branch_location_tab.dart';
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
  late BranchEntity _currentBranch;
  bool _isDeleting = false;
  bool _wasEdited = false;

  // Brand names map for resolving IDs to names
  Map<String, String> _brandNamesMap = {};
  bool _isLoadingBrands = true;

  @override
  void initState() {
    super.initState();
    _currentBranch = widget.branch;
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    final catalogsRepository = InjectorApp.resolve<CatalogsRepository>();
    final result = await catalogsRepository.getBrands();

    if (!mounted) return;

    result.fold(
      (error) {
        // On error, brands will show as IDs (fallback)
        setState(() => _isLoadingBrands = false);
      },
      (brands) {
        setState(() {
          _brandNamesMap = {for (var b in brands) b.id: b.name};
          _isLoadingBrands = false;
        });
      },
    );
  }

  void _navigateToEdit() async {
    final result = await Navigator.push<BranchEntity>(
      context,
      MaterialPageRoute(
        builder: (context) => EditBranchPage(branch: _currentBranch),
      ),
    );

    if (!mounted) return;

    // Always return to services tab after visiting edit screen
    setState(() {
      _selectedTabIndex = 0;
    });

    // Update branch data if edit was successful
    if (result != null) {
      setState(() {
        _currentBranch = result;
        _wasEdited = true;
      });
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final confirmController = TextEditingController();
    bool isConfirmValid = false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red[600]),
                  const SizedBox(width: 8),
                  const Text(BranchConstants.deleteBranchTitle),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Eliminar "${_currentBranch.name}"?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(BranchConstants.deleteBranchConfirmMessage),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmController,
                    decoration: InputDecoration(
                      hintText: BranchConstants.deleteBranchConfirmHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText:
                          confirmController.text.isNotEmpty && !isConfirmValid
                          ? BranchConstants.deleteBranchConfirmError
                          : null,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        isConfirmValid =
                            value.toLowerCase().trim() ==
                            BranchConstants.deleteBranchConfirmWord;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(BranchConstants.cancel),
                ),
                ElevatedButton(
                  onPressed: isConfirmValid
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(BranchConstants.deleteBranchButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      unawaited(_deleteBranch());
    }
  }

  Future<void> _deleteBranch() async {
    setState(() => _isDeleting = true);

    final deleteBranchUseCase = InjectorApp.resolve<DeleteBranchUseCase>();
    final result = await deleteBranchUseCase.call(_currentBranch.id!);

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Navigate back with true to indicate deletion
        Navigator.pop(context, true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Return indicator of change if branch was edited
        Navigator.pop(context, _wasEdited ? _currentBranch : null);
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text('Sede ${_currentBranch.name}'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          actions: [
            if (_isDeleting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                tooltip: BranchConstants.deleteBranchTitle,
                onPressed: _showDeleteConfirmationDialog,
              ),
          ],
        ),
        body: Column(
          children: [
            // Hero image
            _buildHeroImage(),

            // Branch info card with resolved brand names
            BranchInfoCard(
              branch: _currentBranch,
              brandNamesMap: _brandNamesMap,
              isLoadingBrands: _isLoadingBrands,
            ),

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
      ), // Close Scaffold
    ); // Close PopScope
  }

  Widget _buildHeroImage() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(color: Colors.grey[300]),
      child:
          _currentBranch.profileImageUrl != null &&
              _currentBranch.profileImageUrl!.isNotEmpty
          ? Image.network(
              _currentBranch.profileImageUrl!,
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
              _currentBranch.name,
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
        return BranchServicesTab(
          branchId: _currentBranch.id ?? '',
          branchName: _currentBranch.name,
        );
      case 1:
        return BranchScheduleTab(
          branchId: _currentBranch.id ?? '',
          branchName: _currentBranch.name,
        );
      case 2:
        return BranchLocationTab(branch: _currentBranch);
      case 3:
        // Trigger navigation and show placeholder while transitioning
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedTabIndex == 3) {
            _navigateToEdit();
          }
        });
        return const Center(child: CircularProgressIndicator());
      default:
        return const SizedBox.shrink();
    }
  }
}
