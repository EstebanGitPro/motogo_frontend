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
  final String branchName;
  final String branchPhone;
  final List<MotorcycleEntity> motorcycles;
  final MotorcycleEntity? selectedMotorcycle;
  final String problemDescription;
  final List<UploadedEvidence> uploadedEvidence;
  final Set<ServiceType> selectedServiceTypes;
  final bool isUploadingPhoto;
  final bool isSubmitting;
  final String? errorMessage;
  final bool hasLoadedEvidence;

  const RequestDiagnosticLoaded({
    required this.branchName,
    required this.branchPhone,
    required this.motorcycles,
    this.selectedMotorcycle,
    this.problemDescription = '',
    this.uploadedEvidence = const [],
    this.selectedServiceTypes = const {},
    this.isUploadingPhoto = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.hasLoadedEvidence = false,
  });

  /// Whether the form is valid and can be submitted.
  bool get isValid =>
      selectedMotorcycle != null &&
      problemDescription.isNotEmpty &&
      selectedServiceTypes.isNotEmpty;

  /// Generates the WhatsApp message preview.
  String get messagePreview {
    if (selectedMotorcycle == null) return '';

    final serviceLabels = selectedServiceTypes.map((t) => t.label).join(', ');
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
    final serviceText = serviceLabels.isEmpty
        ? RequestDiagnosticConstants.msgServicePlaceholder
        : serviceLabels;

    return '''
${RequestDiagnosticConstants.msgGreeting} $branchName, ${RequestDiagnosticConstants.msgDiagnosticRequest}
${RequestDiagnosticConstants.msgPlate} $plate
${RequestDiagnosticConstants.msgYear} $year
${RequestDiagnosticConstants.msgProblem} $problemText
${RequestDiagnosticConstants.msgServiceType} $serviceText
$photosInfo
''';
  }

  RequestDiagnosticLoaded copyWith({
    String? branchName,
    String? branchPhone,
    List<MotorcycleEntity>? motorcycles,
    MotorcycleEntity? selectedMotorcycle,
    String? problemDescription,
    List<UploadedEvidence>? uploadedEvidence,
    Set<ServiceType>? selectedServiceTypes,
    bool? isUploadingPhoto,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    bool? hasLoadedEvidence,
  }) {
    return RequestDiagnosticLoaded(
      branchName: branchName ?? this.branchName,
      branchPhone: branchPhone ?? this.branchPhone,
      motorcycles: motorcycles ?? this.motorcycles,
      selectedMotorcycle: selectedMotorcycle ?? this.selectedMotorcycle,
      problemDescription: problemDescription ?? this.problemDescription,
      uploadedEvidence: uploadedEvidence ?? this.uploadedEvidence,
      selectedServiceTypes: selectedServiceTypes ?? this.selectedServiceTypes,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasLoadedEvidence: hasLoadedEvidence ?? this.hasLoadedEvidence,
    );
  }

  @override
  List<Object?> get props => [
    branchName,
    branchPhone,
    motorcycles,
    selectedMotorcycle,
    problemDescription,
    uploadedEvidence,
    selectedServiceTypes,
    isUploadingPhoto,
    isSubmitting,
    errorMessage,
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
