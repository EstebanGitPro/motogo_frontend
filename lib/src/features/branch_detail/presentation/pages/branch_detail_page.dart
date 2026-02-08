import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/presentation/bloc/branch_detail_bloc.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/request_diagnostic/presentation/pages/request_diagnostic_page.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page displaying the full detail of a branch/store.
///
/// Shows header with image, contact info, schedules, and services.
class BranchDetailPage extends StatelessWidget {
  final String branchId;
  final String branchName;

  const BranchDetailPage({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectorApp.resolve<BranchDetailBloc>()
            ..add(LoadBranchDetail(branchId)),
      child: _BranchDetailView(branchName: branchName),
    );
  }
}

class _BranchDetailView extends StatelessWidget {
  final String branchName;

  const _BranchDetailView({required this.branchName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(branchName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocBuilder<BranchDetailBloc, BranchDetailState>(
        builder: (context, state) {
          if (state is BranchDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BranchDetailError) {
            return _buildErrorState(context, state.message);
          }

          if (state is BranchDetailLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BranchDetailLoaded state) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(state.detail),
                _buildInfoCard(state.detail, state.isOpenNow),
                _buildContactSection(state.detail),
                _buildScheduleSection(state.schedules),
                _buildServicesSection(state.services),
                const SizedBox(height: 100), // Space for bottom buttons
              ],
            ),
          ),
        ),
        _buildBottomButtons(context, state.detail),
      ],
    );
  }

  Widget _buildHeader(BranchDetailEntity detail) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final headerHeight = (screenHeight * 0.25).clamp(150.0, 250.0);
        return SizedBox(
          height: headerHeight,
          width: double.infinity,
          child:
              detail.profileImageUrl != null &&
                  detail.profileImageUrl!.isNotEmpty
              ? Image.network(
                  detail.profileImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                )
              : _buildImagePlaceholder(),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(Icons.store, size: 64, color: Colors.grey[500]),
      ),
    );
  }

  Widget _buildInfoCard(BranchDetailEntity detail, bool isOpenNow) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTypeBadge(detail),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpenNow ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isOpenNow
                    ? BranchDetailConstants.statusOpen
                    : BranchDetailConstants.statusClosed,
                style: TextStyle(
                  color: isOpenNow ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  detail.fullAddress.isNotEmpty
                      ? detail.fullAddress
                      : 'Dirección no disponible',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BranchDetailEntity detail) {
    final isWorkshop = detail.isWorkshop;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isWorkshop ? Colors.blue : Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isWorkshop
            ? BranchDetailConstants.typeWorkshop
            : BranchDetailConstants.typeStore,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactSection(BranchDetailEntity detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BranchDetailConstants.sectionContact,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.phone, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    detail.phoneNumber ??
                        BranchDetailConstants.phoneNotAvailable,
                    style: TextStyle(
                      fontSize: 16,
                      color: detail.phoneNumber != null
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
                if (detail.phoneNumber != null)
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.green),
                    onPressed: () => _openWhatsApp(detail.phoneNumber!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(List<ScheduleDetailEntity> schedules) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BranchDetailConstants.sectionSchedule,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: schedules.isEmpty
                ? Text(
                    BranchDetailConstants.noScheduleAvailable,
                    style: TextStyle(color: Colors.grey[600]),
                  )
                : Column(children: _buildScheduleRows(schedules)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScheduleRows(List<ScheduleDetailEntity> schedules) {
    // Group by day and sort
    final grouped = <int, ScheduleDetailEntity>{};
    for (final schedule in schedules) {
      if (!grouped.containsKey(schedule.dayOfWeek)) {
        grouped[schedule.dayOfWeek] = schedule;
      }
    }

    final sortedDays = grouped.keys.toList()..sort();
    final now = DateTime.now();

    return sortedDays.map((day) {
      final schedule = grouped[day]!;
      final isToday = day == now.weekday;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                schedule.dayName +
                    (isToday ? ' ${BranchDetailConstants.dayToday}' : ''),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.blue[700] : Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                schedule.isClosed
                    ? BranchDetailConstants.dayClosed
                    : '${schedule.openingTime} - ${schedule.closingTime}',
                style: TextStyle(
                  color: schedule.isClosed ? Colors.grey : Colors.black87,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildServicesSection(List<BranchServiceEntity> services) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BranchDetailConstants.sectionServices,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          if (services.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                BranchDetailConstants.noServicesAvailable,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...services.map((service) => _buildServiceCard(service)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BranchServiceEntity service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.build_circle_outlined, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  BranchDetailConstants.viewReviews,
                  style: TextStyle(color: Colors.blue[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            service.serviceType,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, BranchDetailEntity detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _openGoogleMaps(detail.latitude, detail.longitude),
                icon: const Icon(Icons.directions),
                label: const Text(BranchDetailConstants.buttonHowToGet),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToDiagnostic(context, detail),
                icon: const Icon(Icons.build),
                label: const Text(BranchDetailConstants.buttonSendDiagnostic),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(Config.googleMapsDirectionsUrl(lat, lng));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Remove non-numeric characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToDiagnostic(BuildContext context, BranchDetailEntity detail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDiagnosticPage(
          branchId: detail.id,
          branchName: detail.name,
          branchPhone: detail.phoneNumber ?? '',
        ),
      ),
    );
  }
}
