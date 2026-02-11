import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/domain/entity/completed_service_entity.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

/// Page displaying the service history for a motorcycle.
///
/// Shows completed services with quoted/final prices, representative notes,
/// and diagnostic references. Currently uses mock data until the backend
/// endpoint is implemented.
class MotorcycleHistoryPage extends StatelessWidget {
  final MotorcycleEntity motorcycle;

  const MotorcycleHistoryPage({super.key, required this.motorcycle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MotorcycleConstants.motorcycleHistoryTitle),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildMotorcycleHeader(),
          const Divider(height: 1),
          Expanded(child: _buildServiceList()),
        ],
      ),
    );
  }

  Widget _buildMotorcycleHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.two_wheeler, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  motorcycle.licensePlate.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildSubtitle(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    if (motorcycle.year != null) parts.add('Año: ${motorcycle.year}');
    if (motorcycle.currentMileage != null) {
      parts.add('${motorcycle.currentMileage} km');
    }
    return parts.isEmpty ? '' : parts.join(' | ');
  }

  Widget _buildServiceList() {
    final mockServices = _getMockServices();

    if (mockServices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 72, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                MotorcycleConstants.noServiceHistory,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                MotorcycleConstants.noServiceHistorySubtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockServices.length,
      itemBuilder: (context, index) {
        return _ServiceHistoryCard(service: mockServices[index]);
      },
    );
  }

  /// Mock data to visualize the UI while the backend is not ready.
  List<CompletedServiceEntity> _getMockServices() {
    return [
      CompletedServiceEntity(
        id: 'svc-001',
        diagnosticId: 'diag-abc-123',
        serviceName: 'Cambio de aceite y filtro',
        status: 'FINALIZADO',
        quotedPrice: 85000,
        finalPrice: 82000,
        representativeNotes:
            'Se realizó cambio de aceite sintético 10W40 y filtro de aceite. Moto en buen estado general.',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      CompletedServiceEntity(
        id: 'svc-002',
        diagnosticId: 'diag-abc-456',
        serviceName: 'Revisión de frenos',
        status: 'EN_PROCESO',
        quotedPrice: 120000,
        finalPrice: null,
        representativeNotes:
            'Pastillas delanteras desgastadas al 80%. Se requiere cambio urgente.',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      CompletedServiceEntity(
        id: 'svc-003',
        diagnosticId: null,
        serviceName: 'Sincronización general',
        status: 'SOLICITADO',
        quotedPrice: 150000,
        finalPrice: null,
        representativeNotes: null,
        date: DateTime.now(),
      ),
    ];
  }
}

class _ServiceHistoryCard extends StatelessWidget {
  final CompletedServiceEntity service;

  const _ServiceHistoryCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: service name + status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    service.serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 12),

            // Date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 15, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy', 'es').format(service.date),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price section
            _buildPriceSection(),

            // Representative notes
            if (service.representativeNotes != null &&
                service.representativeNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 18, color: Colors.blue[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MotorcycleConstants.representativeNotesLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service.representativeNotes!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            // Diagnostic reference
            if (service.diagnosticId != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.link, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${MotorcycleConstants.diagnosticRefLabel}: ${service.diagnosticId!.substring(0, service.diagnosticId!.length.clamp(0, 12))}...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final (label, color) = switch (service.status) {
      'FINALIZADO' => (MotorcycleConstants.statusCompleted, Colors.green),
      'EN_PROCESO' => (MotorcycleConstants.statusInProgress, Colors.orange),
      'SOLICITADO' => (MotorcycleConstants.statusRequested, Colors.blue),
      _ => (service.status, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color[700] ?? color,
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    final formatter = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Row(
      children: [
        // Quoted price
        Expanded(
          child: _buildPriceItem(
            label: MotorcycleConstants.quotedPriceLabel,
            value: service.quotedPrice != null
                ? formatter.format(service.quotedPrice)
                : '—',
            icon: Icons.request_quote,
            color: Colors.blue[600]!,
          ),
        ),
        const SizedBox(width: 12),
        // Final price
        Expanded(
          child: _buildPriceItem(
            label: MotorcycleConstants.finalPriceLabel,
            value: service.finalPrice != null
                ? formatter.format(service.finalPrice)
                : '—',
            icon: Icons.payments,
            color: Colors.green[600]!,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
