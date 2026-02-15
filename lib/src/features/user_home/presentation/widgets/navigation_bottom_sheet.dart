import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';

/// Bottom sheet displayed during in-app navigation.
///
/// Shows the navigation target name, estimated distance/time,
/// and action buttons that adapt to immersive vs overview mode.
class NavigationBottomSheet extends StatelessWidget {
  final bool isLoadingRoute;
  final bool isImmersiveMode;
  final BranchMarkerEntity? navigationTarget;
  final double? activeDistanceKm;
  final double? activeDurationMin;
  final double? liveDistanceKm;
  final double? liveDurationMin;
  final VoidCallback onBeginImmersive;
  final VoidCallback onCancelRoute;
  final VoidCallback? onOpenGoogleMaps;

  const NavigationBottomSheet({
    super.key,
    required this.isLoadingRoute,
    required this.isImmersiveMode,
    required this.navigationTarget,
    required this.activeDistanceKm,
    required this.activeDurationMin,
    required this.liveDistanceKm,
    required this.liveDurationMin,
    required this.onBeginImmersive,
    required this.onCancelRoute,
    this.onOpenGoogleMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: isLoadingRoute ? _buildLoading() : _buildContent(),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text(CommonConstants.loadingRoute),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final hasRoute = activeDistanceKm != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Branch name + route info
        _buildRouteInfo(),
        const SizedBox(height: 16),
        // Action buttons
        if (!isImmersiveMode && hasRoute) ...[
          _buildStartButton(),
          const SizedBox(height: 10),
          _buildCancelAndMapsRow(),
        ] else ...[
          _buildImmersiveActions(),
        ],
      ],
    );
  }

  Widget _buildRouteInfo() {
    final distanceKm = liveDistanceKm ?? activeDistanceKm;
    final durationMin = liveDurationMin ?? activeDurationMin;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.directions, color: Colors.blue[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                navigationTarget?.name ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              if (distanceKm != null && durationMin != null)
                Text(
                  '${distanceKm.toStringAsFixed(1)} km · '
                  '${durationMin.round()} ${CommonConstants.estimatedTime}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onBeginImmersive,
        icon: const Icon(Icons.navigation_rounded, size: 20),
        label: const Text(
          CommonConstants.startNavigation,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelAndMapsRow() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancelRoute,
            icon: const Icon(Icons.close, size: 18),
            label: const Text(CommonConstants.cancelRoute),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onOpenGoogleMaps,
            icon: const Icon(Icons.map, size: 18),
            label: const Text(
              CommonConstants.openInGoogleMaps,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              side: BorderSide(color: Colors.blue[600]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImmersiveActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onCancelRoute,
            icon: const Icon(Icons.close, size: 18),
            label: const Text(CommonConstants.cancelRoute),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onOpenGoogleMaps,
            icon: const Icon(Icons.map, size: 18),
            label: const Text(
              CommonConstants.openInGoogleMaps,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
