import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/request_diagnostic_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/camera_permission_service.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/enums/evidence_angle.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';
import 'package:motogo_frontend/src/features/request_diagnostic/presentation/bloc/request_diagnostic_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page for requesting a diagnostic from a branch via WhatsApp.
///
/// The user selects their motorcycle, describes the problem, attaches photos,
/// toggles permission for the branch, and sends a formatted message via WhatsApp.
class RequestDiagnosticPage extends StatelessWidget {
  final String branchId;
  final String branchName;
  final String branchPhone;

  const RequestDiagnosticPage({
    super.key,
    required this.branchId,
    required this.branchName,
    required this.branchPhone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InjectorApp.resolve<RequestDiagnosticBloc>()
        ..add(
          InitializeRequest(
            branchId: branchId,
            branchName: branchName,
            branchPhone: branchPhone,
          ),
        ),
      child: const _RequestDiagnosticView(),
    );
  }
}

class _RequestDiagnosticView extends StatefulWidget {
  const _RequestDiagnosticView();

  @override
  State<_RequestDiagnosticView> createState() => _RequestDiagnosticViewState();
}

class _RequestDiagnosticViewState extends State<_RequestDiagnosticView> {
  final _problemController = TextEditingController();
  bool _isPickingPhoto = false;

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestDiagnosticBloc, RequestDiagnosticState>(
      listener: (context, state) {
        if (state is RequestDiagnosticLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        // Handle success: open WhatsApp
        if (state is RequestDiagnosticLoaded && state.successMessage != null) {
          _openWhatsApp(context, state);
        }
        // Load evidence when motorcycle is selected and not yet loaded
        if (state is RequestDiagnosticLoaded &&
            state.selectedMotorcycle?.id != null &&
            !state.isUploadingPhoto &&
            !state.hasLoadedEvidence) {
          context.read<RequestDiagnosticBloc>().add(
            LoadEvidence(state.selectedMotorcycle!.id!),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is RequestDiagnosticLoaded
                  ? '${RequestDiagnosticConstants.pageTitle} ${state.branchName}'
                  : RequestDiagnosticConstants.pageTitle,
            ),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, RequestDiagnosticState state) {
    if (state is RequestDiagnosticLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is RequestDiagnosticError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(state.message, textAlign: TextAlign.center),
        ),
      );
    }

    if (state is RequestDiagnosticLoaded) {
      return _buildForm(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildForm(BuildContext context, RequestDiagnosticLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMotorcycleSection(context, state),
          const SizedBox(height: 16),
          _buildProblemSection(context, state),
          const SizedBox(height: 16),
          _buildPhotosSection(context, state),
          const SizedBox(height: 16),
          _buildPermissionSection(context, state),
          const SizedBox(height: 16),
          _buildPreviewSection(state),
          const SizedBox(height: 24),
          _buildSubmitButton(context, state),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildMotorcycleSection(
    BuildContext context,
    RequestDiagnosticLoaded state,
  ) {
    if (state.motorcycles.isEmpty) {
      return _buildSectionCard(
        title: RequestDiagnosticConstants.sectionMyMoto,
        child: const Text(RequestDiagnosticConstants.noMotorcyclesMessage),
      );
    }

    return _buildSectionCard(
      title: RequestDiagnosticConstants.sectionMyMoto,
      child: DropdownButtonFormField<MotorcycleEntity>(
        initialValue: state.selectedMotorcycle,
        decoration: InputDecoration(
          labelText: RequestDiagnosticConstants.selectMotorcycle,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: state.motorcycles.map((moto) {
          final year = moto.year?.toString() ?? '';
          return DropdownMenuItem(
            value: moto,
            child: Text(
              '${moto.licensePlate} ${year.isNotEmpty ? "- $year" : ""}',
            ),
          );
        }).toList(),
        onChanged: (moto) {
          if (moto != null) {
            context.read<RequestDiagnosticBloc>().add(SelectMotorcycle(moto));
          }
        },
      ),
    );
  }

  Widget _buildProblemSection(
    BuildContext context,
    RequestDiagnosticLoaded state,
  ) {
    return _buildSectionCard(
      title: RequestDiagnosticConstants.sectionProblem,
      child: TextFormField(
        controller: _problemController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: RequestDiagnosticConstants.problemHint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: (value) {
          context.read<RequestDiagnosticBloc>().add(
            UpdateProblemDescription(value),
          );
        },
      ),
    );
  }

  Widget _buildPhotosSection(
    BuildContext context,
    RequestDiagnosticLoaded state,
  ) {
    return _buildSectionCard(
      title: RequestDiagnosticConstants.sectionPhotos,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.isUploadingPhoto)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.hasLoadedEvidence
                        ? 'Subiendo foto...'
                        : 'Cargando evidencias...',
                  ),
                ],
              ),
            ),
          if (state.selectedMotorcycle == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Selecciona una moto primero para agregar fotos',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.uploadedEvidence.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.uploadedEvidence.length) {
                    // Add button
                    if (state.uploadedEvidence.length >=
                            RequestDiagnosticConstants.maxPhotos ||
                        state.isUploadingPhoto ||
                        _isPickingPhoto) {
                      return const SizedBox.shrink();
                    }
                    return _buildAddPhotoButton(context);
                  }
                  return _buildPhotoTile(
                    context,
                    state.uploadedEvidence[index],
                    index,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoButton(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isPickingPhoto,
      child: Opacity(
        opacity: _isPickingPhoto ? 0.6 : 1,
        child: GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Icon(Icons.add, size: 32, color: Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(
    BuildContext context,
    UploadedEvidence evidence,
    int index,
  ) {
    // Get angle label for display
    String? angleLabel;
    if (evidence.angle != null) {
      final angle = EvidenceAngle.fromValue(evidence.angle!);
      angleLabel = angle?.label;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(evidence.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 8,
              child: GestureDetector(
                onTap: () => context.read<RequestDiagnosticBloc>().add(
                  RemovePhoto(index),
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (angleLabel != null)
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: Text(
              angleLabel,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
      ],
    );
  }

  void _showPickerOptions(BuildContext context) {
    final bloc = context.read<RequestDiagnosticBloc>();
    // First show angle selection
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selecciona el ángulo de la foto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...EvidenceAngle.values.map(
              (angle) => ListTile(
                leading: Icon(_getAngleIcon(angle)),
                title: Text(angle.label),
                subtitle: Text(_getAngleDescription(angle)),
                onTap: () {
                  Navigator.pop(context);
                  _showSourceOptions(context, bloc, angle);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAngleIcon(EvidenceAngle angle) {
    switch (angle) {
      case EvidenceAngle.frontal:
        return Icons.arrow_upward;
      case EvidenceAngle.lateral:
        return Icons.arrow_forward;
      case EvidenceAngle.rear:
        return Icons.arrow_downward;
    }
  }

  String _getAngleDescription(EvidenceAngle angle) {
    switch (angle) {
      case EvidenceAngle.frontal:
        return 'Vista de frente de la moto';
      case EvidenceAngle.lateral:
        return 'Vista de lado (izq o der)';
      case EvidenceAngle.rear:
        return 'Vista de atrás de la moto';
    }
  }

  void _showSourceOptions(
    BuildContext context,
    RequestDiagnosticBloc bloc,
    EvidenceAngle angle,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Foto ${angle.label}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(CommonConstants.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(bloc, ImageSource.camera, angle);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(CommonConstants.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(bloc, ImageSource.gallery, angle);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
    RequestDiagnosticBloc bloc,
    ImageSource source,
    EvidenceAngle angle,
  ) async {
    if (_isPickingPhoto) return;
    if (mounted) {
      setState(() {
        _isPickingPhoto = true;
      });
    }

    try {
      // Request camera permission before using camera
      if (source == ImageSource.camera) {
        final permissionResult = await CameraPermissionService.instance
            .requestPermissionWithResult();

        if (permissionResult == CameraPermissionResult.permanentlyDenied) {
          return;
        }

        if (permissionResult == CameraPermissionResult.denied) {
          return;
        }
      }

      // Create new picker each time to prevent Android resource leaks
      final picker = ImagePicker();

      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      // Add delay to let Android release camera buffers before next capture
      if (source == ImageSource.camera) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }

      if (picked != null && mounted) {
        bloc.add(AddPhoto(picked.path, angle));
      }
    } catch (e) {
      // Handle error silently - log for debugging
      debugPrint('Image picker error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingPhoto = false;
        });
      }
    }
  }

  Widget _buildPermissionSection(
    BuildContext context,
    RequestDiagnosticLoaded state,
  ) {
    return _buildSectionCard(
      title: RequestDiagnosticConstants.sectionPermission,
      child: SwitchListTile(
        title: Text(
          '${RequestDiagnosticConstants.permissionLabel} a ${state.branchName}',
        ),
        subtitle: const Text(
          RequestDiagnosticConstants.permissionSubtitle,
          style: TextStyle(fontSize: 12),
        ),
        value: state.isPermissionGranted,
        onChanged: (_) =>
            context.read<RequestDiagnosticBloc>().add(const TogglePermission()),
        activeColor: Colors.blue[600],
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPreviewSection(RequestDiagnosticLoaded state) {
    return _buildSectionCard(
      title: RequestDiagnosticConstants.sectionPreview,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[600],
            child: const Icon(Icons.phone, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.messagePreview,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    RequestDiagnosticLoaded state,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isValid && !state.isSubmitting
            ? () => context.read<RequestDiagnosticBloc>().add(
                const SubmitRequest(),
              )
            : null,
        icon: state.isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send),
        label: const Text(RequestDiagnosticConstants.sendButton),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(
    BuildContext context,
    RequestDiagnosticLoaded state,
  ) async {
    final phone = state.branchPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final message = Uri.encodeComponent(state.messagePreview);
    final url = Uri.parse('https://wa.me/$phone?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(RequestDiagnosticConstants.whatsappError),
          ),
        );
      }
    }
  }
}
