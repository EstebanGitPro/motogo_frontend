import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/request_diagnostic_constants.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/usecase/create_diagnostic_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/grant_permission_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/list_permissions_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/enums/evidence_angle.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/delete_evidence_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/get_evidence_usecase.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/usecases/upload_evidence_usecase.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/usecases/get_my_motorcycles_usecase.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';

part 'request_diagnostic_event.dart';
part 'request_diagnostic_state.dart';

/// BLoC for managing the diagnostic request form.
///
/// Handles motorcycle selection, immediate photo upload, diagnostic creation,
/// permission granting, and WhatsApp message generation.
class RequestDiagnosticBloc
    extends Bloc<RequestDiagnosticEvent, RequestDiagnosticState> {
  final GetMyMotorcyclesUseCase _getMyMotorcyclesUseCase;
  final UploadEvidenceUseCase _uploadEvidenceUseCase;
  final DeleteEvidenceUseCase _deleteEvidenceUseCase;
  final GetEvidenceUseCase _getEvidenceUseCase;
  final CreateDiagnosticUseCase _createDiagnosticUseCase;
  final GrantPermissionUseCase _grantPermissionUseCase;
  final ListPermissionsUseCase _listPermissionsUseCase;

  /// Maximum number of photos allowed.
  static const int maxPhotos = 4;

  RequestDiagnosticBloc({
    required GetMyMotorcyclesUseCase getMyMotorcyclesUseCase,
    required UploadEvidenceUseCase uploadEvidenceUseCase,
    required DeleteEvidenceUseCase deleteEvidenceUseCase,
    required GetEvidenceUseCase getEvidenceUseCase,
    required CreateDiagnosticUseCase createDiagnosticUseCase,
    required GrantPermissionUseCase grantPermissionUseCase,
    required ListPermissionsUseCase listPermissionsUseCase,
  }) : _getMyMotorcyclesUseCase = getMyMotorcyclesUseCase,
       _uploadEvidenceUseCase = uploadEvidenceUseCase,
       _deleteEvidenceUseCase = deleteEvidenceUseCase,
       _getEvidenceUseCase = getEvidenceUseCase,
       _createDiagnosticUseCase = createDiagnosticUseCase,
       _grantPermissionUseCase = grantPermissionUseCase,
       _listPermissionsUseCase = listPermissionsUseCase,
       super(const RequestDiagnosticInitial()) {
    on<InitializeRequest>(_onInitializeRequest);
    on<SelectMotorcycle>(_onSelectMotorcycle);
    on<UpdateProblemDescription>(_onUpdateProblemDescription);
    on<AddPhoto>(_onAddPhoto);
    on<RemovePhoto>(_onRemovePhoto);
    on<TogglePermission>(_onTogglePermission);
    on<SubmitRequest>(_onSubmitRequest);
    on<LoadEvidence>(_onLoadEvidence);
  }

  Future<void> _onInitializeRequest(
    InitializeRequest event,
    Emitter<RequestDiagnosticState> emit,
  ) async {
    emit(const RequestDiagnosticLoading());

    final result = await _getMyMotorcyclesUseCase();

    if (result.isLeft) {
      emit(RequestDiagnosticError(result.left.message));
      return;
    }

    final motorcycles = result.right;
    final firstMoto = motorcycles.isNotEmpty ? motorcycles.first : null;
    final motorcycleId = firstMoto?.id;
    final shouldLoadEvidence = motorcycleId != null;

    final baseState = RequestDiagnosticLoaded(
      branchId: event.branchId,
      branchName: event.branchName,
      branchPhone: event.branchPhone,
      motorcycles: motorcycles,
      selectedMotorcycle: firstMoto,
      hasLoadedEvidence: !shouldLoadEvidence,
      isUploadingPhoto: shouldLoadEvidence,
    );
    emit(baseState);

    if (!shouldLoadEvidence) return;

    final evidenceResult = await _getEvidenceUseCase(
      motorcycleId: motorcycleId,
    );

    evidenceResult.fold(
      (error) => emit(
        baseState.copyWith(
          uploadedEvidence: const [],
          isUploadingPhoto: false,
          hasLoadedEvidence: true,
        ),
      ),
      (existingEvidence) {
        final uploadedList = existingEvidence
            .map(
              (e) => UploadedEvidence(
                id: e.id,
                imageUrl: e.imageUrl,
                angle: e.angle,
              ),
            )
            .toList();
        emit(
          baseState.copyWith(
            uploadedEvidence: uploadedList,
            isUploadingPhoto: false,
            hasLoadedEvidence: true,
          ),
        );
      },
    );

    // Hydrate permission toggle from backend
    await _hydratePermissionState(
      motorcycleId: motorcycleId,
      branchId: event.branchId,
      emit: emit,
    );
  }

  Future<void> _onSelectMotorcycle(
    SelectMotorcycle event,
    Emitter<RequestDiagnosticState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RequestDiagnosticLoaded) return;

    // Reset evidence list and show loading
    emit(
      currentState.copyWith(
        selectedMotorcycle: event.motorcycle,
        uploadedEvidence: const [],
        isUploadingPhoto: true,
        hasLoadedEvidence: false,
        clearError: true,
      ),
    );

    // Load existing evidence for the selected motorcycle
    final motorcycleId = event.motorcycle.id;
    if (motorcycleId == null) {
      emit(
        currentState.copyWith(
          selectedMotorcycle: event.motorcycle,
          uploadedEvidence: const [],
          isUploadingPhoto: false,
        ),
      );
      return;
    }

    final result = await _getEvidenceUseCase(motorcycleId: motorcycleId);

    result.fold(
      (error) => emit(
        currentState.copyWith(
          selectedMotorcycle: event.motorcycle,
          uploadedEvidence: const [],
          isUploadingPhoto: false,
          // Don't show error for evidence loading - silently use empty list
          hasLoadedEvidence: true,
        ),
      ),
      (existingEvidence) {
        // Convert MotorcycleEvidenceEntity to UploadedEvidence
        final uploadedList = existingEvidence
            .map(
              (e) => UploadedEvidence(
                id: e.id,
                imageUrl: e.imageUrl,
                angle: e.angle,
              ),
            )
            .toList();
        emit(
          currentState.copyWith(
            selectedMotorcycle: event.motorcycle,
            uploadedEvidence: uploadedList,
            isUploadingPhoto: false,
            hasLoadedEvidence: true,
          ),
        );
      },
    );

    // Hydrate permission toggle from backend
    await _hydratePermissionState(
      motorcycleId: motorcycleId,
      branchId: currentState.branchId,
      emit: emit,
    );
  }

  /// Loads evidence for a specific motorcycle (used when navigating between branches).
  Future<void> _onLoadEvidence(
    LoadEvidence event,
    Emitter<RequestDiagnosticState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RequestDiagnosticLoaded) return;

    // Show loading indicator
    emit(
      currentState.copyWith(
        isUploadingPhoto: true,
        hasLoadedEvidence: false,
        clearError: true,
      ),
    );

    final result = await _getEvidenceUseCase(motorcycleId: event.motorcycleId);

    result.fold(
      (error) => emit(
        currentState.copyWith(
          uploadedEvidence: const [],
          isUploadingPhoto: false,
          // Don't show error for evidence loading - silently use empty list
          hasLoadedEvidence: true,
        ),
      ),
      (existingEvidence) {
        final uploadedList = existingEvidence
            .map(
              (e) => UploadedEvidence(
                id: e.id,
                imageUrl: e.imageUrl,
                angle: e.angle,
              ),
            )
            .toList();
        emit(
          currentState.copyWith(
            uploadedEvidence: uploadedList,
            isUploadingPhoto: false,
            hasLoadedEvidence: true,
          ),
        );
      },
    );
  }

  void _onUpdateProblemDescription(
    UpdateProblemDescription event,
    Emitter<RequestDiagnosticState> emit,
  ) {
    final currentState = state;
    if (currentState is RequestDiagnosticLoaded) {
      emit(currentState.copyWith(problemDescription: event.description));
    }
  }

  /// Immediately uploads photo to server when added.
  Future<void> _onAddPhoto(
    AddPhoto event,
    Emitter<RequestDiagnosticState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RequestDiagnosticLoaded) return;
    if (currentState.uploadedEvidence.length >= maxPhotos) return;
    if (currentState.selectedMotorcycle == null) return;
    final motorcycleId = currentState.selectedMotorcycle!.id;
    if (motorcycleId == null) return;
    final photoFile = File(event.photoPath);

    // Show uploading state
    emit(currentState.copyWith(isUploadingPhoto: true, clearError: true));

    // Upload immediately to Firebase + API
    final result = await _uploadEvidenceUseCase(
      motorcycleId: motorcycleId,
      photoFile: photoFile,
      angle: event.angle.value,
      description: 'Pre-visita diagnóstico',
    );

    try {
      if (photoFile.existsSync()) {
        photoFile.deleteSync();
      }
    } catch (_) {}

    if (result.isLeft) {
      emit(
        currentState.copyWith(
          isUploadingPhoto: false,
          errorMessage: result.left.message,
        ),
      );
      return;
    }

    final evidence = result.right;
    final newEvidence = [
      ...currentState.uploadedEvidence,
      UploadedEvidence(
        id: evidence.id,
        imageUrl: evidence.imageUrl,
        angle: evidence.angle,
      ),
    ];
    emit(
      currentState.copyWith(
        uploadedEvidence: newEvidence,
        isUploadingPhoto: false,
      ),
    );
  }

  /// Deletes evidence from server when removed.
  Future<void> _onRemovePhoto(
    RemovePhoto event,
    Emitter<RequestDiagnosticState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RequestDiagnosticLoaded) return;
    if (currentState.selectedMotorcycle == null) return;
    final motorcycleId = currentState.selectedMotorcycle!.id;
    if (motorcycleId == null) return;
    if (event.index < 0 ||
        event.index >= currentState.uploadedEvidence.length) {
      return;
    }

    final evidenceToRemove = currentState.uploadedEvidence[event.index];

    // Remove from UI immediately
    final newEvidence = [...currentState.uploadedEvidence];
    newEvidence.removeAt(event.index);
    emit(currentState.copyWith(uploadedEvidence: newEvidence));

    // Delete from server (fire and forget - UI already updated)
    await _deleteEvidenceUseCase(
      motorcycleId: motorcycleId,
      evidenceId: evidenceToRemove.id,
    );
  }

  /// Fetches existing permission state from the backend and updates the toggle.
  ///
  /// If no permission row exists for this motorcycle+branch, defaults to false.
  Future<void> _hydratePermissionState({
    required String motorcycleId,
    required String branchId,
    required Emitter<RequestDiagnosticState> emit,
  }) async {
    final currentState = state;
    if (currentState is! RequestDiagnosticLoaded) return;

    final permResult = await _listPermissionsUseCase(
      motorcycleId: motorcycleId,
    );

    if (permResult.isRight) {
      final permissions = permResult.right;
      // Find the permission for this specific branch
      final matchingPerm = permissions
          .where((p) => p.branchId == branchId)
          .toList();

      final isActive = matchingPerm.isNotEmpty
          ? matchingPerm.first.active
          : false;

      final latestState = state;
      if (latestState is RequestDiagnosticLoaded) {
        emit(latestState.copyWith(isPermissionGranted: isActive));
      }
    }
    // On error, keep the current default (false)
  }

  /// Toggles the permission and immediately calls the API to persist the change.
  ///
  /// The toggle fires independently from the form submit so the user can
  /// grant/revoke lookup permission without re-sending the WhatsApp message.
  Future<void> _onTogglePermission(
    TogglePermission event,
    Emitter<RequestDiagnosticState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RequestDiagnosticLoaded) return;
    if (currentState.selectedMotorcycle == null) return;
    final motorcycleId = currentState.selectedMotorcycle!.id;
    if (motorcycleId == null) return;

    final newValue = !currentState.isPermissionGranted;

    // Optimistic UI update
    emit(currentState.copyWith(isPermissionGranted: newValue));

    // Fire API call — non-blocking, but rollback on failure
    final result = await _grantPermissionUseCase(
      motorcycleId: motorcycleId,
      branchId: currentState.branchId,
      active: newValue,
    );

    if (result.isLeft) {
      // Rollback on failure
      final latestState = state;
      if (latestState is RequestDiagnosticLoaded) {
        emit(
          latestState.copyWith(
            isPermissionGranted: !newValue,
            errorMessage: result.left.message,
          ),
        );
      }
    } else {
      // Show backend success message
      final latestState = state;
      if (latestState is RequestDiagnosticLoaded) {
        emit(latestState.copyWith(permissionMessage: result.right.message));
      }
    }
  }

  Future<void> _onSubmitRequest(
    SubmitRequest event,
    Emitter<RequestDiagnosticState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RequestDiagnosticLoaded) return;
    if (!currentState.isValid) return;

    final motorcycleId = currentState.selectedMotorcycle!.id;
    if (motorcycleId == null) return;

    emit(currentState.copyWith(isSubmitting: true, clearError: true));

    // Step 1: Create diagnostic via API
    final diagnosticResult = await _createDiagnosticUseCase(
      motorcycleId: motorcycleId,
      problemDescription: currentState.problemDescription,
      branchId: currentState.branchId,
    );

    if (diagnosticResult.isLeft) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          errorMessage: diagnosticResult.left.message,
        ),
      );
      return;
    }

    // Step 2: Ready for WhatsApp — the page will handle opening it
    emit(
      currentState.copyWith(
        isSubmitting: false,
        successMessage: RequestDiagnosticConstants.submitSuccess,
      ),
    );
  }
}
