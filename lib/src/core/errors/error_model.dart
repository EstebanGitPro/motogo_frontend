class ErrorModel {
  final String message;
  final String? description;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;
  final bool isError;

  ErrorModel({
    required this.message,
    this.description,
    this.statusCode,
    this.errorCode,
    this.details,
    this.isError = true,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      message: json['message'] ?? json['msg'] ?? 'Error desconocido',
      description: json['description'] ?? json['detail'],
      statusCode: json['status_code'] ?? json['status'],
      errorCode: json['error_code'] ?? json['code'],
      details: json['details'] ?? json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (description != null) 'description': description,
      if (statusCode != null) 'status_code': statusCode,
      if (errorCode != null) 'error_code': errorCode,
      if (details != null) 'details': details,
    };
  }

  /// Método para obtener el mensaje a mostrar al usuario
  String get displayMessage {
    return description ?? message;
  }

  /// Verifica si es un error de validación específico
  bool get isValidationError => errorCode?.startsWith('VALIDATION_') == true;

  /// Obtiene errores de campo específicos si existen
  Map<String, String>? get fieldErrors {
    if (details != null && details is Map<String, dynamic>) {
      final fieldErrors = <String, String>{};
      details!.forEach((key, value) {
        if (value is List) {
          fieldErrors[key] = value.join(', ');
        } else if (value is String) {
          fieldErrors[key] = value;
        }
      });
      return fieldErrors.isNotEmpty ? fieldErrors : null;
    }
    return null;
  }
}
