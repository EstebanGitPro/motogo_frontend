import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_services/data/datasources/branch_services_datasource.dart';
import 'package:motogo_frontend/src/features/branch_services/data/models/branch_service_model.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/pages/branch_services_page.dart';
import 'package:motogo_frontend/src/features/branch_services/presentation/widgets/service_card_widget.dart';

/// Tab content widget that navigates to the full services management page
/// and shows associated services with their ratings below.
///
/// Representatives can see reviews but cannot rate services.
class BranchServicesTab extends StatefulWidget {
  final String branchId;
  final String branchName;

  const BranchServicesTab({
    super.key,
    required this.branchId,
    this.branchName = '',
  });

  @override
  State<BranchServicesTab> createState() => _BranchServicesTabState();
}

class _BranchServicesTabState extends State<BranchServicesTab> {
  List<BranchServiceEntity> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final dataSource = InjectorApp.resolve<BranchServicesDataSource>();
    final Either<ErrorModel, List<BranchServiceModel>> result = await dataSource
        .getBranchServices(widget.branchId);

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _errorMessage = error.message;
          _isLoading = false;
        });
      },
      (models) {
        setState(() {
          _services = models.map((m) => m.toEntity()).toList();
          _isLoading = false;
        });
      },
    );
  }

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

          // Navigate to services management card
          _buildManageServicesCard(context),
          const SizedBox(height: 24),

          // Associated services section
          Text(
            BranchDetailConstants.associatedServices,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Services list
          _buildServicesList(),
        ],
      ),
    );
  }

  Widget _buildManageServicesCard(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BranchServicesPage(
              branchId: widget.branchId,
              branchName: widget.branchName,
            ),
          ),
        );
        // Reload services after returning from management page
        if (mounted) {
          setState(() => _isLoading = true);
          _loadServices();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.build_outlined,
                color: Colors.blue[600],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestionar Servicios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Asocia servicios del catálogo a esta sede',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red[400]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_services.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.build_circle_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              BranchDetailConstants.noAssociatedServices,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: _services
          .map((service) => ServiceCardWidget(service: service))
          .toList(),
    );
  }
}
