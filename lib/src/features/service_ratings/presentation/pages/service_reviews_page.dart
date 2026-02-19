import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/bloc/service_reviews_bloc.dart';
import 'package:intl/intl.dart';

/// Page displaying service reviews fetched from the API.
///
/// Shows average rating summary, rating breakdown by star,
/// and individual review cards with reviewer info.
class ServiceReviewsPage extends StatelessWidget {
  final String serviceId;
  final String serviceName;

  const ServiceReviewsPage({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(serviceName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: BlocBuilder<ServiceReviewsBloc, ServiceReviewsState>(
        builder: (context, state) {
          if (state is ServiceReviewsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ServiceReviewsError) {
            return _buildErrorState(context, state.message);
          }
          if (state is ServiceReviewsLoaded) {
            return _buildContent(state.summary);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ServiceReviewsBloc>().add(
                FetchServiceReviews(serviceId: serviceId),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ServiceReviewSummaryEntity summary) {
    if (summary.totalReviews == 0) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(summary),
          const SizedBox(height: 16),
          _buildReviewsList(summary.reviews),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aún no hay reseñas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sé el primero en calificar este servicio',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(ServiceReviewSummaryEntity summary) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: big average number + stars
              Column(
                children: [
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStarRow(summary.averageRating, size: 18),
                ],
              ),
              const SizedBox(width: 24),
              // Right: breakdown bars
              Expanded(
                child: Column(
                  children: List.generate(5, (i) {
                    final star = 5 - i;
                    final count = summary.breakdown[star] ?? 0;
                    return _buildRatingBar(star, count, summary.totalReviews);
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.totalReviews} reseña${summary.totalReviews != 1 ? 's' : ''}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final fraction = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            child: Text(
              '$stars',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: Colors.grey[200],
                color: Colors.blue[700],
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating, {double size = 16}) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.3;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
          fullStars,
          (_) => Icon(Icons.star, size: size, color: Colors.amber),
        ),
        if (hasHalf) Icon(Icons.star_half, size: size, color: Colors.amber),
        ...List.generate(
          emptyStars,
          (_) => Icon(Icons.star_border, size: size, color: Colors.amber),
        ),
      ],
    );
  }

  Widget _buildReviewsList(List<ServiceReviewItemEntity> reviews) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: reviews.map((review) => _buildReviewCard(review)).toList(),
      ),
    );
  }

  Widget _buildReviewCard(ServiceReviewItemEntity review) {
    final timeAgo = _formatTimeAgo(review.ratedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: avatar + name + date
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child: Text(
                  review.initials,
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Stars
          _buildStarRow(review.rating.toDouble(), size: 16),
          // Comment text (if available)
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
          // Motorcycle info (if available)
          if (review.motorcycleModel != null &&
              review.motorcycleModel!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.two_wheeler, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  review.motorcycleModel!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Formats a DateTime into a relative time string in Spanish.
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} día${diff.inDays != 1 ? 's' : ''}';
    }
    if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'Hace $weeks semana${weeks != 1 ? 's' : ''}';
    }

    return DateFormat('d MMM yyyy', 'es').format(dateTime);
  }
}
