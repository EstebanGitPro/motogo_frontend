import 'package:flutter/material.dart';

/// A reusable gradient header card with a circular icon, title, and subtitle.
///
/// Used across admin and registration pages to provide a consistent
/// branded header with a blue-toned gradient background.
class GradientHeaderCard extends StatelessWidget {
  /// The icon to display inside the circular container.
  final IconData icon;

  /// The header title text (displayed in bold white).
  final String title;

  /// The subtitle text (displayed in white70).
  final String subtitle;

  /// Gradient colors. Defaults to `[Colors.blue, Colors.blueAccent]`.
  final List<Color> gradientColors;

  const GradientHeaderCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.gradientColors = const [Colors.blue, Colors.blueAccent],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
