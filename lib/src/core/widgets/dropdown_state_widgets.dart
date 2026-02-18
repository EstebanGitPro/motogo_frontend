import 'package:flutter/material.dart';

/// Shared state widgets for dropdown catalog selectors.
///
/// Eliminates duplication between [DepartmentDropdown] and
/// [CityDropdown] loading, error, and disabled state widgets.
class DropdownStateWidgets {
  /// Displays a container with a loading indicator for dropdown fields.
  ///
  /// Shows an icon, loading message, and a small progress indicator.
  static Widget buildLoadingState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  /// Displays an error container with a red theme for dropdown fields.
  ///
  /// Shows an error icon and the provided error message.
  static Widget buildErrorState({required String message}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  /// Displays a disabled container for dropdown fields that depend on
  /// a prerequisite selection (e.g., city depends on department).
  ///
  /// Shows an icon and a gray-themed hint message.
  static Widget buildDisabledState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }
}
