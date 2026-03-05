import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiwi/kiwi.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/bloc/service_reviews_bloc.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/pages/service_reviews_page.dart';

/// Reusable service card widget used on both client and representative views.
///
/// Shows service name, type, optional star rating, and action links.
/// - Client side: shows "Ver Reseñas" + "Calificar" (via [onRate] callback)
/// - Representative side: shows "Ver Reseñas" only ([onRate] is null)
class ServiceCardWidget extends StatelessWidget {
  final BranchServiceEntity service;

  /// If non-null, shows the "Calificar" link and calls this when tapped.
  final VoidCallback? onRate;

  const ServiceCardWidget({super.key, required this.service, this.onRate});

  bool get _canRate => onRate != null;

  @override
  Widget build(BuildContext context) {
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
                if (service.averageRating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        service.averageRating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '(${service.totalReviews})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToReviews(context),
                      child: Text(
                        BranchDetailConstants.viewReviews,
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                    ),
                    if (_canRate) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onRate,
                        child: Text(
                          BranchDetailConstants.rateService,
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
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

  void _navigateToReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              KiwiContainer().resolve<ServiceReviewsBloc>()
                ..add(FetchServiceReviews(serviceId: service.id)),
          child: ServiceReviewsPage(
            serviceId: service.id,
            serviceName: service.name,
          ),
        ),
      ),
    );
  }
}
