import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

/// Service for handling camera permission requests.
///
/// Provides methods to check, request, and manage camera permissions
/// using the permission_handler package.
class CameraPermissionService {
  static final CameraPermissionService _instance = CameraPermissionService._();
  static CameraPermissionService get instance => _instance;
  CameraPermissionService._();

  /// Checks if camera permission is granted.
  Future<bool> isCameraPermissionGranted() async {
    final status = await permission_handler.Permission.camera.status;
    return status.isGranted;
  }

  /// Requests camera permission from the user.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> requestCameraPermission() async {
    final status = await permission_handler.Permission.camera.request();
    return status.isGranted;
  }

  /// Checks if camera permission is permanently denied.
  /// When permanently denied, user must go to app settings to grant permission.
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await permission_handler.Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Opens the app settings page for permission management.
  Future<bool> openAppSettings() async {
    return permission_handler.openAppSettings();
  }

  /// Requests camera permission and handles all cases.
  /// Returns a [CameraPermissionResult] with the outcome.
  Future<CameraPermissionResult> requestPermissionWithResult() async {
    // First check if already granted
    if (await isCameraPermissionGranted()) {
      return CameraPermissionResult.granted;
    }

    // Check if permanently denied
    if (await isCameraPermissionPermanentlyDenied()) {
      return CameraPermissionResult.permanentlyDenied;
    }

    // Request permission
    final status = await permission_handler.Permission.camera.request();

    if (status.isGranted) {
      return CameraPermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return CameraPermissionResult.permanentlyDenied;
    } else {
      return CameraPermissionResult.denied;
    }
  }
}

/// Result of a camera permission request.
enum CameraPermissionResult {
  /// Permission was granted by the user.
  granted,

  /// Permission was denied by the user (can be requested again).
  denied,

  /// Permission was permanently denied (user must go to settings).
  permanentlyDenied,
}
