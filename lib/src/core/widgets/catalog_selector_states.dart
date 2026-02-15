import 'package:flutter/material.dart';

/// Shared state widgets for catalog chip selectors.
///
/// Eliminates duplication between [BrandsSelector] and
/// [DisplacementRangeSelector] loading, error, and empty states.

/// Displays a centered loading indicator for catalog data.
class CatalogLoadingState extends StatelessWidget {
  const CatalogLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Displays an error message when catalog data fails to load.
class CatalogErrorState extends StatelessWidget {
  final String message;

  const CatalogErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays a warning when no catalog items are available.
class CatalogEmptyState extends StatelessWidget {
  final String message;

  const CatalogEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.orange[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
