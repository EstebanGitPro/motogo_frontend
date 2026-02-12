part of 'request_diagnostic_bloc.dart';

/// Represents an uploaded evidence photo.
class UploadedEvidence extends Equatable {
  final String id;
  final String imageUrl;
  final String? angle;

  const UploadedEvidence({
    required this.id,
    required this.imageUrl,
    this.angle,
  });

  @override
  List<Object?> get props => [id, imageUrl, angle];
}

/// States for the RequestDiagnosticBloc.
abstract class RequestDiagnosticState extends Equatable {
  const RequestDiagnosticState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state.
class RequestDiagnosticInitial extends RequestDiagnosticState {
  const RequestDiagnosticInitial();
}

/// Loading user motorcycles.
class RequestDiagnosticLoading extends RequestDiagnosticState {
  const RequestDiagnosticLoading();
}

/// Form ready for user input.
class RequestDiagnosticLoaded extends RequestDiagnosticState {
  final String branchId;
  final String branchName;
  final String branchPhone;
  final List<MotorcycleEntity> motorcycles;
  final MotorcycleEntity? selectedMotorcycle;
  final String problemDescription;
  final List<UploadedEvidence> uploadedEvidence;
  final bool isPermissionGranted;
  final bool isUploadingPhoto;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String? permissionMessage;
  final bool hasLoadedEvidence;

  const RequestDiagnosticLoaded({
    required this.branchId,
    required this.branchName,
    required this.branchPhone,
    required this.motorcycles,
    this.selectedMotorcycle,
    this.problemDescription = '',
    this.uploadedEvidence = const [],
    this.isPermissionGranted = false,
    this.isUploadingPhoto = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.permissionMessage,
    this.hasLoadedEvidence = false,
  });

  /// Whether the form is valid and can be submitted.
  bool get isValid =>
      selectedMotorcycle != null && problemDescription.isNotEmpty;

  /// Generates the WhatsApp message preview.
  String get messagePreview {
    if (selectedMotorcycle == null) return '';

    final plate = selectedMotorcycle!.licensePlate;
    final year =
        selectedMotorcycle!.year?.toString() ??
        RequestDiagnosticConstants.msgNotApplicable;
    final photosInfo = uploadedEvidence.isNotEmpty
        ? '${uploadedEvidence.length} ${RequestDiagnosticConstants.msgPhotosAttached}'
        : '';

    final problemText = problemDescription.isEmpty
        ? RequestDiagnosticConstants.msgProblemPlaceholder
        : problemDescription;

    return '''
${RequestDiagnosticConstants.msgGreeting} $branchName, ${RequestDiagnosticConstants.msgDiagnosticRequest}
${RequestDiagnosticConstants.msgPlate} $plate
${RequestDiagnosticConstants.msgYear} $year
${RequestDiagnosticConstants.msgProblem} $problemText
$photosInfo
''';
  }

  RequestDiagnosticLoaded copyWith({
    String? branchId,
    String? branchName,
    String? branchPhone,
    List<MotorcycleEntity>? motorcycles,
    MotorcycleEntity? selectedMotorcycle,
    String? problemDescription,
    List<UploadedEvidence>? uploadedEvidence,
    bool? isPermissionGranted,
    bool? isUploadingPhoto,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    String? permissionMessage,
    bool clearError = false,
    bool? hasLoadedEvidence,
  }) {
    return RequestDiagnosticLoaded(
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      branchPhone: branchPhone ?? this.branchPhone,
      motorcycles: motorcycles ?? this.motorcycles,
      selectedMotorcycle: selectedMotorcycle ?? this.selectedMotorcycle,
      problemDescription: problemDescription ?? this.problemDescription,
      uploadedEvidence: uploadedEvidence ?? this.uploadedEvidence,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage,
      permissionMessage: permissionMessage,
      hasLoadedEvidence: hasLoadedEvidence ?? this.hasLoadedEvidence,
    );
  }

  @override
  List<Object?> get props => [
    branchId,
    branchName,
    branchPhone,
    motorcycles,
    selectedMotorcycle,
    problemDescription,
    uploadedEvidence,
    isPermissionGranted,
    isUploadingPhoto,
    isSubmitting,
    errorMessage,
    successMessage,
    permissionMessage,
    hasLoadedEvidence,
  ];
}

/// Error loading motorcycles.
class RequestDiagnosticError extends RequestDiagnosticState {
  final String message;

  const RequestDiagnosticError(this.message);

  @override
  List<Object?> get props => [message];
}
