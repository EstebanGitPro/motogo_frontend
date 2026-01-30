import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String roleDisplayName;
  final Color primaryColor;
  final IconData icon;

  const ProfileHeader({
    required this.title,
    required this.subtitle,
    required this.roleDisplayName,
    required this.primaryColor,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Center(
      child: Column(
        children: [
          Container(
            width: isMobile ? 70 : 80,
            height: isMobile ? 70 : 80,
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: primaryColor, size: isMobile ? 35 : 40),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: isMobile ? 24 : 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              fontSize: isMobile ? 16 : 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              roleDisplayName,
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
