class ErrorModel {
  final String message;
  final bool isError;
  final String? errorCode;

  ErrorModel({required this.message, this.isError = true, this.errorCode});

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      message: json['message'] ?? 'Unknown error',
      isError: json['isError'] ?? true,
      errorCode: json['error_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isError': isError,
      if (errorCode != null) 'error_code': errorCode,
    };
  }
}
