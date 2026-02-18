import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motogo_frontend/src/core/constants/image_picker_constants.dart';
import 'package:motogo_frontend/src/core/services/camera_permission_service.dart';

/// Widget for selecting and previewing an image.
///
/// Allows picking from gallery or camera with preview and remove functionality.
class ImagePickerWidget extends StatefulWidget {
  /// The currently selected image file.
  final File? selectedImage;

  /// Existing image URL for edit mode (displays network image if no file selected).
  final String? existingImageUrl;

  /// Callback when an image is selected or removed.
  final ValueChanged<File?> onImageChanged;

  /// Callback when user requests to remove an existing (already uploaded) image.
  /// This is separate from onImageChanged(null) which only clears the local file.
  final VoidCallback? onExistingImageRemoved;

  /// Whether the widget is enabled for interaction.
  final bool enabled;

  /// Whether an upload is in progress.
  final bool isUploading;

  /// Optional label text.
  final String label;

  /// Optional hint text.
  final String hint;

  const ImagePickerWidget({
    super.key,
    required this.selectedImage,
    this.existingImageUrl,
    required this.onImageChanged,
    this.onExistingImageRemoved,
    this.enabled = true,
    this.isUploading = false,
    this.label = 'Imagen de perfil',
    this.hint = 'Toca para agregar una imagen',
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  bool _isPickingImage = false;

  void _showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  /// Handles camera permission check. Returns true if permission granted.
  Future<bool> _handleCameraPermission(BuildContext context) async {
    final permissionResult = await CameraPermissionService.instance
        .requestPermissionWithResult();

    if (permissionResult == CameraPermissionResult.permanentlyDenied) {
      if (context.mounted) _showPermissionDeniedDialog(context);
      return false;
    }

    if (permissionResult == CameraPermissionResult.denied) {
      if (context.mounted) {
        _showSnackBar(
          context,
          ImagePickerConstants.permissionDenied,
          backgroundColor: Colors.orange,
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    if (_isPickingImage) return;
    if (mounted) setState(() => _isPickingImage = true);

    try {
      if (source == ImageSource.camera) {
        final granted = await _handleCameraPermission(context);
        if (!granted) return;
      }

      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      // Give Android a moment to release camera buffers
      if (source == ImageSource.camera) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }

      if (pickedFile != null) {
        widget.onImageChanged(File(pickedFile.path));
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          '${ImagePickerConstants.selectImageError}: $e',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(ImagePickerConstants.permissionTitle),
        content: const Text(ImagePickerConstants.permissionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(ImagePickerConstants.cancelButton),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              CameraPermissionService.instance.openAppSettings();
            },
            child: const Text(ImagePickerConstants.goToSettings),
          ),
        ],
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: const Text(ImagePickerConstants.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text(ImagePickerConstants.chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              // Show delete option for local file selection
              if (widget.selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(ImagePickerConstants.removeImage),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onImageChanged(null);
                  },
                ),
              // Show delete option for already uploaded image
              if (widget.selectedImage == null &&
                  widget.existingImageUrl != null &&
                  widget.existingImageUrl!.isNotEmpty &&
                  widget.onExistingImageRemoved != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(ImagePickerConstants.removeImage),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onExistingImageRemoved!();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.enabled && !widget.isUploading && !_isPickingImage
              ? () => _showPickerOptions(context)
              : null,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = MediaQuery.of(context).size.height;
              final responsiveHeight = (screenHeight * 0.18).clamp(
                120.0,
                200.0,
              );
              return Container(
                height: responsiveHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.selectedImage != null
                        ? Colors.blue[400]!
                        : Colors.grey[300]!,
                    width: widget.selectedImage != null ? 2 : 1,
                  ),
                ),
                child: _buildContainerChild(context),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Selects the appropriate child widget for the image container.
  Widget _buildContainerChild(BuildContext context) {
    if (widget.isUploading) return _buildUploadingState();
    if (widget.selectedImage != null) {
      return _buildSelectedImagePreview(context);
    }

    final hasExistingImage =
        widget.existingImageUrl != null && widget.existingImageUrl!.isNotEmpty;
    if (hasExistingImage) return _buildExistingImagePreview(context);

    return _buildPlaceholder();
  }

  Widget _buildUploadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text(ImagePickerConstants.uploadingImage),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.file(widget.selectedImage!, fit: BoxFit.cover),
        ),
        _buildEditButton(context),
      ],
    );
  }

  Widget _buildExistingImagePreview(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.network(
            widget.existingImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(
                Icons.broken_image,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
          ),
        ),
        _buildEditButton(context),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
          onPressed: widget.enabled && !_isPickingImage
              ? () => _showPickerOptions(context)
              : null,
          tooltip: ImagePickerConstants.changeImage,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          widget.hint,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          ImagePickerConstants.optionalLabel,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
