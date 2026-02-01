import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/franchise_constants.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_bloc.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_event.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_state.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';

/// Page for managing a franchise and its branches.
class ManageFranchisePage extends StatefulWidget {
  final String franchiseId;

  const ManageFranchisePage({super.key, required this.franchiseId});

  @override
  State<ManageFranchisePage> createState() => _ManageFranchisePageState();
}

class _ManageFranchisePageState extends State<ManageFranchisePage> {
  /// Tracks if any changes were made (link/unlink/update)
  bool _hasChanges = false;

  /// Tracks how many times data has been loaded
  /// First load (loadCount == 0) is initial, subsequent loads mean data changed
  int _loadCount = 0;

  void _markChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageFranchiseBloc, ManageFranchiseState>(
      listener: (context, state) {
        if (state is ManageFranchiseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ManageFranchiseDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ManageFranchiseUpdated) {
          _markChanged();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ManageFranchiseLoaded) {
          // After initial load, any reload means link/unlink was performed
          if (_loadCount > 0) {
            _markChanged();
          }
          _loadCount++;
        }
      },
      builder: (context, state) {
        if (state is ManageFranchiseLoading) {
          return Scaffold(
            appBar: AppBar(
              leading: _buildBackButton(context),
              title: const Text(FranchiseConstants.loadingTitle),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ManageFranchiseLoaded) {
          return _buildLoadedState(context, state);
        }

        return Scaffold(
          appBar: AppBar(
            leading: _buildBackButton(context),
            title: const Text(FranchiseConstants.errorTitle),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
          ),
          body: const Center(
            child: Text(FranchiseConstants.errorLoadingFranchise),
          ),
        );
      },
    );
  }

  /// Custom back button that returns true when changes were made
  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context, _hasChanges ? true : null),
    );
  }

  Widget _buildLoadedState(BuildContext context, ManageFranchiseLoaded state) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: _buildBackButton(context),
        title: Text(
          '${FranchiseConstants.franchisePrefix}${state.franchise.name}',
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue[600]),
            onPressed: () => _showEditDialog(context, state),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      FranchiseConstants.deleteFranchiseMenu,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linked branches section
            _buildSectionHeader(
              '${FranchiseConstants.linkedBranchesSection} (${state.linkedBranches.length})',
            ),
            const SizedBox(height: 12),
            if (state.linkedBranches.isEmpty)
              _buildEmptyMessage(FranchiseConstants.noLinkedBranches)
            else
              ...state.linkedBranches.map(
                (b) => _buildLinkedBranchCard(context, b, state),
              ),

            const SizedBox(height: 24),

            // Available branches section
            _buildSectionHeader(
              '${FranchiseConstants.availableBranchesSection} (${state.availableBranches.length})',
            ),
            const SizedBox(height: 12),
            if (state.availableBranches.isEmpty)
              _buildEmptyMessage(FranchiseConstants.noAvailableBranches)
            else
              ...state.availableBranches.map(
                (b) => _buildAvailableBranchCard(context, b),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(message, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  Widget _buildLinkedBranchCard(
    BuildContext context,
    BranchEntity branch,
    ManageFranchiseLoaded state,
  ) {
    final canUnlink = state.linkedBranches.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        title: Text(
          branch.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          branch.address,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeColor(branch.establishmentType),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getTypeLabel(branch.establishmentType),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: canUnlink
            ? IconButton(
                icon: Icon(Icons.link_off, color: Colors.blue[600]),
                onPressed: () => _unlinkBranch(context, branch),
              )
            : Tooltip(
                message: FranchiseConstants.mustHaveOneBranch,
                child: Icon(Icons.link_off, color: Colors.grey[400]),
              ),
      ),
    );
  }

  Widget _buildAvailableBranchCard(BuildContext context, BranchEntity branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ListTile(
        title: Text(
          branch.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          branch.address,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeColor(branch.establishmentType),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getTypeLabel(branch.establishmentType),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.add, color: Colors.blue[600]),
          onPressed: () => _linkBranch(context, branch),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'WORKSHOP':
        return Colors.green;
      case 'STORE':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'WORKSHOP':
        return FranchiseConstants.typeWorkshop;
      case 'STORE':
        return FranchiseConstants.typeStore;
      case 'WORKSHOP_STORE':
        return FranchiseConstants.typeWorkshopStore;
      default:
        return type;
    }
  }

  void _unlinkBranch(BuildContext context, BranchEntity branch) {
    if (branch.id == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(FranchiseConstants.unlinkBranchTitle),
        content: Text(
          '${FranchiseConstants.unlinkBranchConfirm} "${branch.name}" ${FranchiseConstants.unlinkBranchSuffix}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(FranchiseConstants.cancelAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ManageFranchiseBloc>().add(
                UnlinkBranchEvent(branch.id!),
              );
            },
            child: const Text(FranchiseConstants.unlinkAction),
          ),
        ],
      ),
    );
  }

  void _linkBranch(BuildContext context, BranchEntity branch) {
    if (branch.id == null) return;

    context.read<ManageFranchiseBloc>().add(LinkBranchEvent(branch.id!));
  }

  void _showEditDialog(BuildContext context, ManageFranchiseLoaded state) {
    final nameController = TextEditingController(text: state.franchise.name);
    final descController = TextEditingController(
      text: state.franchise.description ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(FranchiseConstants.editFranchiseTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: FranchiseConstants.franchiseNameLabel,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: FranchiseConstants.descriptionLabel,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(FranchiseConstants.cancelAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ManageFranchiseBloc>().add(
                UpdateFranchiseEvent(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                ),
              );
            },
            child: const Text(FranchiseConstants.saveAction),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(FranchiseConstants.deleteFranchiseTitle),
        content: const Text(FranchiseConstants.deleteFranchiseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(FranchiseConstants.cancelAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ManageFranchiseBloc>().add(
                const DeleteFranchiseEvent(),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(FranchiseConstants.deleteAction),
          ),
        ],
      ),
    );
  }
}
