import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';

/// Shared helpers for service status display and formatting.
///
/// Centralises status label/color mappings and price/date formatting
/// to avoid duplication across [ServiceDetailPage] and
/// [SearchMotorcyclePage].

/// Returns a human-readable label for the given backend status code.
String getStatusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'PENDIENTE':
    case 'SOLICITADO':
      return MotorcycleConstants.statusPending;
    case 'EN_PROCESO':
      return MotorcycleConstants.statusInProgress;
    case 'FINALIZADO':
      return MotorcycleConstants.statusCompleted;
    case 'CANCELADO':
      return MotorcycleConstants.statusCancelled;
    default:
      return status;
  }
}

/// Returns a colour associated with the given backend status code.
Color getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PENDIENTE':
    case 'SOLICITADO':
      return Colors.orange;
    case 'EN_PROCESO':
      return Colors.blue;
    case 'FINALIZADO':
      return Colors.green;
    case 'CANCELADO':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

/// Formats a [price] as a string with thousands separators (dot).
///
/// Example: `185000` → `"185.000"`.
String formatServicePrice(double price) {
  final intPrice = price.toInt();
  final str = intPrice.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < str.length; i++) {
    buffer.write(str[i]);
    final remaining = str.length - 1 - i;
    if (remaining > 0 && remaining % 3 == 0) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}

/// Formats a [date] as `dd/MM/yyyy`.
String formatServiceDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}'
      '/${date.month.toString().padLeft(2, '0')}'
      '/${date.year}';
}

/// Formats a [date] as `dd/MM/yyyy HH:mm`.
String formatServiceDateTime(DateTime date) {
  return '${formatServiceDate(date)}'
      ' ${date.hour.toString().padLeft(2, '0')}'
      ':${date.minute.toString().padLeft(2, '0')}';
}
