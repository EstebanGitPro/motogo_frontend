import 'package:flutter/material.dart';

/// Reusable card for catalog list items with a circular icon, title, subtitle,
/// and optional trailing widget.
///
/// Used in [CategoryLinesPage] to deduplicate the category and line card
/// layouts.
class CatalogItemCard extends StatelessWidget {
  final IconData icon;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CatalogItemCard({
    super.key,
    required this.icon,
    this.iconBackgroundColor,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
