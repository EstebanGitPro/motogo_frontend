import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

class BackendErrorWidget extends StatelessWidget {
  final ErrorModel errorModel;
  final VoidCallback? onRetry;
  final bool showDetails;

  const BackendErrorWidget({
    super.key,
    required this.errorModel,
    this.onRetry,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorModel.displayMessage,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (errorModel.description != null &&
              errorModel.description != errorModel.message) ...[
            const SizedBox(height: 8),
            Text(
              errorModel.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
          ],

          if (showDetails && errorModel.errorCode != null) ...[
            const SizedBox(height: 8),
            Text(
              'Código: ${errorModel.errorCode}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade600,
                fontSize: 12,
              ),
            ),
          ],

          if (errorModel.fieldErrors != null) ...[
            const SizedBox(height: 12),
            Text(
              'Errores en campos:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...errorModel.fieldErrors!.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  '• ${entry.key}: ${entry.value}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ],

          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  backgroundColor: Colors.red.shade100,
                ),
                child: const Text('Reintentar'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Método estático para mostrar un SnackBar con el error
  static void showErrorSnackBar(
    BuildContext context,
    ErrorModel errorModel, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(errorModel.displayMessage),
          backgroundColor: Colors.red.shade700,
          duration: duration,
          action: errorModel.description != null
              ? SnackBarAction(
                  label: 'DETALLES',
                  textColor: Colors.white,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Detalles del Error'),
                        content: SingleChildScrollView(
                          child: Text(
                            errorModel.description ??
                                'Sin detalles adicionales',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : null,
        ),
      );
  }
}

/// Widget de utilidad para mostrar errores en formularios
class FormFieldErrorWidget extends StatelessWidget {
  final Map<String, String>? fieldErrors;
  final String fieldName;

  const FormFieldErrorWidget({
    super.key,
    this.fieldErrors,
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    if (fieldErrors == null || !fieldErrors!.containsKey(fieldName)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 12),
      child: Text(
        fieldErrors![fieldName]!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }
}
