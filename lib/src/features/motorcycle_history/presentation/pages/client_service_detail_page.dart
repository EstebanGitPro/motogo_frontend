import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/widgets/service_detail_widgets.dart';

/// Client-side detail view for a completed service.
///
/// Read-only page showing service info (status, branch, prices, services,
/// notes) plus a rating section for FINALIZADO services.
/// Used in the motorcyclist flow: Mis Motocicletas → Historial de Servicios → tap card.
class ClientServiceDetailPage extends StatefulWidget {
  final CompletedServiceEntity service;

  const ClientServiceDetailPage({super.key, required this.service});

  @override
  State<ClientServiceDetailPage> createState() =>
      _ClientServiceDetailPageState();
}

class _ClientServiceDetailPageState extends State<ClientServiceDetailPage> {
  /// Tracks item IDs that have been rated during this session.
  final Set<String> _ratedItemIds = {};

  /// Whether any rating was submitted during this session.
  bool _hasRated = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_hasRated);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(MotorcycleConstants.serviceDetailTitle),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ServiceStatusHeader(
                status: widget.service.status,
                requestDate: widget.service.requestDate,
              ),
              const SizedBox(height: 24),
              ServiceInfoSection(service: widget.service),
              if (widget.service.status.toUpperCase() == 'FINALIZADO' &&
                  widget.service.services.isNotEmpty) ...[
                const SizedBox(height: 24),
                ServiceRatingSection(
                  completedServiceId: widget.service.id,
                  items: widget.service.services,
                  ratedItemIds: _ratedItemIds,
                  onItemRated: (itemId) {
                    setState(() {
                      _ratedItemIds.add(itemId);
                      _hasRated = true;
                    });
                  },
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
