import 'package:flutter/material.dart';

/// Page displaying service reviews with hardcoded mock data.
///
/// Shows average rating summary, rating breakdown, and individual
/// review cards. All data is artificial for preview purposes.
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingSummary(),
            const SizedBox(height: 16),
            _buildReviewsList(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary() {
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
                  const Text(
                    '4.7',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStarRow(4.7, size: 18),
                ],
              ),
              const SizedBox(width: 24),
              // Right: breakdown bars
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 18, 28),
                    _buildRatingBar(4, 7, 28),
                    _buildRatingBar(3, 2, 28),
                    _buildRatingBar(2, 1, 28),
                    _buildRatingBar(1, 0, 28),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '28 reseñas',
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

  Widget _buildReviewsList() {
    final reviews = _getMockReviews();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: reviews.map((review) => _buildReviewCard(review)).toList(),
      ),
    );
  }

  Widget _buildReviewCard(_MockReview review) {
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
                      review.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.timeAgo,
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
          const SizedBox(height: 8),
          // Comment text
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          // Motorcycle info
          Row(
            children: [
              Icon(Icons.two_wheeler, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                review.motorcycle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_MockReview> _getMockReviews() {
    return const [
      _MockReview(
        name: 'Carlos M.',
        initials: 'CM',
        timeAgo: 'Hace 2 días',
        rating: 5,
        comment: 'Excelente servicio, muy rápido y profesional',
        motorcycle: 'Honda CB 160F',
      ),
      _MockReview(
        name: 'Ana P.',
        initials: 'AP',
        timeAgo: 'Hace 5 días',
        rating: 4,
        comment:
            'Buen servicio en general, aunque el tiempo de espera fue un poco más de lo estimado. El mecánico fue amable.',
        motorcycle: 'Yamaha FZ-S',
      ),
      _MockReview(
        name: 'David R.',
        initials: 'DR',
        timeAgo: 'Hace 1 semana',
        rating: 5,
        comment:
            'Recomiendo totalmente este taller. Precios justos y un trato excelente. Mi moto quedó como nueva.',
        motorcycle: 'Suzuki Gixxer 250',
      ),
      _MockReview(
        name: 'María L.',
        initials: 'ML',
        timeAgo: 'Hace 2 semanas',
        rating: 5,
        comment:
            'Muy profesionales, me explicaron todo el proceso y me dieron garantía del trabajo.',
        motorcycle: 'AKT NKD 125',
      ),
      _MockReview(
        name: 'Jorge H.',
        initials: 'JH',
        timeAgo: 'Hace 3 semanas',
        rating: 4,
        comment: 'Buen trabajo, el precio fue razonable. Volvería sin duda.',
        motorcycle: 'Bajaj Pulsar NS200',
      ),
    ];
  }
}

/// Internal mock data class for preview reviews.
class _MockReview {
  final String name;
  final String initials;
  final String timeAgo;
  final int rating;
  final String comment;
  final String motorcycle;

  const _MockReview({
    required this.name,
    required this.initials,
    required this.timeAgo,
    required this.rating,
    required this.comment,
    required this.motorcycle,
  });
}
