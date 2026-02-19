import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/domain/entities/status_transition_entity.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/helpers/service_status_helpers.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/widgets/service_detail_widgets.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';

/// Full-page detail view for a completed service.
///
/// Shows current status, service info, action buttons based on status,
/// and the transition history timeline.
class ServiceDetailPage extends StatefulWidget {
  final CompletedServiceEntity service;

  /// When `true`, shows the rating section for FINALIZADO services.
  /// Should only be `true` on the client (motorcyclist) side.
  final bool canRate;

  const ServiceDetailPage({
    super.key,
    required this.service,
    this.canRate = false,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  @override
  void initState() {
    super.initState();
    // Fetch transition history when entering the page
    context.read<SearchMotorcycleBloc>().add(
      FetchServiceTransitions(serviceId: widget.service.id),
    );
  }

  void _handleStateChanges(BuildContext context, SearchMotorcycleState state) {
    if (state is! SearchMotorcycleLoaded) return;

    _showFeedback(
      context,
      message: state.statusUpdateMessage,
      error: state.statusUpdateError,
      popOnSuccess: true,
    );
    _showFeedback(
      context,
      message: state.deleteServiceMessage,
      error: state.deleteServiceError,
      popOnSuccess: true,
    );
    _showFeedback(
      context,
      message: state.detailsUpdateMessage,
      error: state.detailsUpdateError,
    );
  }

  void _showFeedback(
    BuildContext context, {
    String? message,
    String? error,
    bool popOnSuccess = false,
  }) {
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      if (popOnSuccess) Navigator.of(context).pop();
    } else if (error != null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchMotorcycleBloc, SearchMotorcycleState>(
      listenWhen: (prev, curr) {
        if (prev is SearchMotorcycleLoaded && curr is SearchMotorcycleLoaded) {
          return prev.statusUpdateMessage != curr.statusUpdateMessage ||
              prev.statusUpdateError != curr.statusUpdateError ||
              prev.deleteServiceMessage != curr.deleteServiceMessage ||
              prev.deleteServiceError != curr.deleteServiceError ||
              prev.detailsUpdateMessage != curr.detailsUpdateMessage ||
              prev.detailsUpdateError != curr.detailsUpdateError;
        }
        return false;
      },
      listener: _handleStateChanges,
      builder: (context, state) {
        final isUpdating =
            state is SearchMotorcycleLoaded && state.isUpdatingStatus;
        final isDeleting =
            state is SearchMotorcycleLoaded && state.isDeletingService;
        final transitions = state is SearchMotorcycleLoaded
            ? state.serviceTransitions
            : <StatusTransitionEntity>[];

        return Scaffold(
          appBar: AppBar(
            title: const Text(MotorcycleConstants.serviceDetailTitle),
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
                ServiceInfoSection(
                  service: widget.service,
                  onEdit: _showEditBottomSheet,
                ),
                const SizedBox(height: 24),
                _buildActionButtons(isUpdating),
                const SizedBox(height: 16),
                _buildDeleteButton(isDeleting),
                if (transitions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildTransitionTimeline(transitions),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Action Buttons ────────────────────────────────────────────────

  Widget _buildActionButtons(bool isUpdating) {
    final status = widget.service.status.toUpperCase();

    // Finalized → show rating section (client side only)
    if (status == 'FINALIZADO') {
      return widget.canRate
          ? ServiceRatingSection(
              completedServiceId: widget.service.id,
              items: widget.service.services,
            )
          : const SizedBox.shrink();
    }

    // Cancelled → no actions
    if (status == 'CANCELADO') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (status == 'PENDIENTE') ...[
          _buildPrimaryActionButton(
            isUpdating: isUpdating,
            targetStatus: 'EN_PROCESO',
            icon: Icons.play_arrow,
            label: MotorcycleConstants.startServiceButton,
            color: Colors.blue,
          ),
          const SizedBox(height: 10),
          _buildCancelButton(isUpdating),
        ],
        if (status == 'EN_PROCESO') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUpdating ? null : _showFinalPriceDialog,
              icon: isUpdating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              label: const Text(MotorcycleConstants.finalizeServiceButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildCancelButton(isUpdating),
        ],
      ],
    );
  }

  // ─── Transition History Timeline ───────────────────────────────────

  Widget _buildTransitionTimeline(List<StatusTransitionEntity> transitions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          MotorcycleConstants.transitionHistoryTitle,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        ...transitions.asMap().entries.map((entry) {
          final index = entry.key;
          final transition = entry.value;
          final isLast = index == transitions.length - 1;
          final color = getStatusColor(transition.newStatus);
          final dateStr = formatServiceDateTime(transition.createdAt);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline connector
                SizedBox(
                  width: 28,
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(width: 2, color: Colors.grey[300]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (transition.previousStatus != null) ...[
                              Text(
                                getStatusLabel(transition.previousStatus!),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            Text(
                              getStatusLabel(transition.newStatus),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─── Actions ───────────────────────────────────────────────────────

  void _updateStatus(String newStatus, {double? finalPrice}) {
    context.read<SearchMotorcycleBloc>().add(
      UpdateServiceStatus(
        serviceId: widget.service.id,
        motorcycleId: widget.service.motorcycleId,
        newStatus: newStatus,
        finalPrice: finalPrice,
      ),
    );
  }

  // ─── Edit Bottom Sheet ─────────────────────────────────────────────

  void _showEditBottomSheet() {
    final quotedCtrl = TextEditingController(
      text: widget.service.quotedPrice?.toStringAsFixed(0) ?? '',
    );
    final finalCtrl = TextEditingController(
      text: widget.service.finalPrice?.toStringAsFixed(0) ?? '',
    );
    final notesCtrl = TextEditingController(
      text: widget.service.representativeNotes ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              MotorcycleConstants.editServiceTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Quoted price
            TextField(
              controller: quotedCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: MotorcycleConstants.editQuotedPriceLabel,
                hintText: MotorcycleConstants.editQuotedPriceHint,
                prefixIcon: const Icon(Icons.request_quote),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Final price
            TextField(
              controller: finalCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: MotorcycleConstants.editFinalPriceLabel,
                hintText: MotorcycleConstants.editFinalPriceHint,
                prefixIcon: const Icon(Icons.payments),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Notes
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: MotorcycleConstants.editNotesLabel,
                hintText: MotorcycleConstants.editNotesHint,
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final quoted = double.tryParse(quotedCtrl.text.trim());
                  final finalP = double.tryParse(finalCtrl.text.trim());
                  final notes = notesCtrl.text.trim();

                  context.read<SearchMotorcycleBloc>().add(
                    UpdateServiceDetails(
                      serviceId: widget.service.id,
                      motorcycleId: widget.service.motorcycleId,
                      quotedPrice: quoted,
                      finalPrice: finalP,
                      representativeNotes: notes.isEmpty ? null : notes,
                    ),
                  );
                  Navigator.of(ctx).pop();
                },
                icon: const Icon(Icons.save),
                label: const Text(MotorcycleConstants.editServiceSave),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Final Price Dialog ────────────────────────────────────────────

  void _showFinalPriceDialog() {
    final priceCtrl = TextEditingController(
      text: widget.service.finalPrice?.toStringAsFixed(0) ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(MotorcycleConstants.finalizePriceTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(MotorcycleConstants.finalizePriceMessage),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: MotorcycleConstants.editFinalPriceLabel,
                hintText: MotorcycleConstants.editFinalPriceHint,
                prefixIcon: const Icon(Icons.payments),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateStatus('FINALIZADO');
            },
            child: const Text(MotorcycleConstants.finalizePriceSkip),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final price = double.tryParse(priceCtrl.text.trim());
              _updateStatus('FINALIZADO', finalPrice: price);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text(MotorcycleConstants.finalizePriceConfirm),
          ),
        ],
      ),
    );
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(MotorcycleConstants.cancelServiceButton),
        content: const Text(
          '¿Estás seguro de que deseas cancelar este servicio? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateStatus('CANCELADO');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(MotorcycleConstants.deleteServiceButton),
        content: const Text(MotorcycleConstants.deleteServiceConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<SearchMotorcycleBloc>().add(
                DeleteCompletedService(
                  serviceId: widget.service.id,
                  motorcycleId: widget.service.motorcycleId,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }

  // ─── Reusable Widgets ──────────────────────────────────────────────

  Widget _buildPrimaryActionButton({
    required bool isUpdating,
    required String targetStatus,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isUpdating ? null : () => _updateStatus(targetStatus),
        icon: isUpdating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(bool isUpdating) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isUpdating ? null : () => _confirmCancel(),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text(MotorcycleConstants.cancelServiceButton),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(bool isDeleting) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isDeleting ? null : () => _confirmDelete(),
        icon: isDeleting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
              )
            : const Icon(Icons.delete_outline),
        label: Text(
          isDeleting
              ? 'Eliminando...'
              : MotorcycleConstants.deleteServiceButton,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[700]!),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
