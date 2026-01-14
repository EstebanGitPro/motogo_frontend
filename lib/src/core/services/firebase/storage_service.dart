import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/services/firebase/firebase_token_data_source.dart';

/// Service for handling Firebase Storage operations.
///
/// Provides methods for uploading images with automatic Firebase authentication.
class StorageService {
  final FirebaseTokenDataSource _tokenDataSource;
  final FirebaseAuth _firebaseAuth;
  final FirebaseStorage _firebaseStorage;

  bool _isAuthenticated = false;

  StorageService({
    required FirebaseTokenDataSource tokenDataSource,
    FirebaseAuth? firebaseAuth,
    FirebaseStorage? firebaseStorage,
  }) : _tokenDataSource = tokenDataSource,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  /// Checks if the user is currently authenticated with Firebase.
  bool get isAuthenticated =>
      _isAuthenticated && _firebaseAuth.currentUser != null;

  /// Authenticates with Firebase using a custom token from the backend.
  ///
  /// This should be called before any upload operation.
  /// Returns an error if authentication fails.
  Future<Either<ErrorModel, void>> authenticate() async {
    // Already authenticated
    if (isAuthenticated) {
      return const Right(null);
    }

    // Get custom token from backend
    final tokenResult = await _tokenDataSource.getFirebaseToken();

    return tokenResult.fold((error) => Left(error), (token) async {
      try {
        await _firebaseAuth.signInWithCustomToken(token);
        _isAuthenticated = true;
        return const Right(null);
      } on FirebaseAuthException catch (e) {
        return Left(
          ErrorModel(
            message: _getFirebaseAuthErrorMessage(e.code, e.message),
            errorCode: e.code,
          ),
        );
      } catch (e) {
        final errorString = e.toString();
        return Left(
          ErrorModel(
            message: _getFirebaseAuthErrorMessage(null, errorString),
            errorCode: 'FIREBASE_AUTH_ERROR',
          ),
        );
      }
    });
  }

  /// Signs out from Firebase.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _isAuthenticated = false;
  }

  /// Uploads a single image to Firebase Storage.
  ///
  /// [storagePath] - The full path in Firebase Storage (e.g., 'branches/{id}/profile.jpg')
  /// [file] - The image file to upload
  ///
  /// Returns the download URL on success, or an error on failure.
  Future<Either<ErrorModel, String>> uploadImage({
    required String storagePath,
    required File file,
  }) async {
    // Ensure authenticated
    if (!isAuthenticated) {
      final authResult = await authenticate();
      if (authResult.isLeft) {
        return Left(authResult.left);
      }
    }

    try {
      final ref = _firebaseStorage.ref().child(storagePath);

      // Upload with timeout
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: _getContentType(file.path)),
      );

      // Wait for upload with timeout
      final snapshot = await uploadTask.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          uploadTask.cancel();
          throw Exception('Upload timed out');
        },
      );

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(
        ErrorModel(
          message: _getStorageErrorMessage(e.code, e.message),
          errorCode: e.code,
        ),
      );
    } catch (e) {
      final errorString = e.toString();
      return Left(
        ErrorModel(
          message: _getStorageErrorMessage(null, errorString),
          errorCode: 'UPLOAD_ERROR',
        ),
      );
    }
  }

  /// Uploads a branch profile image.
  ///
  /// Uses the standardized path: branches/{branchId}/profile.jpg
  Future<Either<ErrorModel, String>> uploadBranchImage({
    required String branchId,
    required File file,
  }) {
    final extension = _getExtension(file.path);
    return uploadImage(
      storagePath: 'branches/$branchId/profile.$extension',
      file: file,
    );
  }

  /// Uploads a user avatar image.
  ///
  /// Uses the standardized path: users/{userId}/avatar.jpg
  Future<Either<ErrorModel, String>> uploadUserAvatar({
    required String userId,
    required File file,
  }) {
    final extension = _getExtension(file.path);
    return uploadImage(
      storagePath: 'users/$userId/avatar.$extension',
      file: file,
    );
  }

  /// Uploads multiple images for a user (e.g., motorcycle photos).
  ///
  /// [basePath] - Base path (e.g., 'users/{userId}')
  /// [files] - List of image files
  /// [maxImages] - Maximum number of images to upload (default: 4)
  ///
  /// Returns a list of download URLs for successfully uploaded images.
  Future<Either<ErrorModel, List<String>>> uploadMultiple({
    required String basePath,
    required List<File> files,
    int maxImages = 4,
  }) async {
    // Limit the number of files
    final filesToUpload = files.take(maxImages).toList();
    final downloadUrls = <String>[];
    final errors = <String>[];

    for (var i = 0; i < filesToUpload.length; i++) {
      final file = filesToUpload[i];
      final extension = _getExtension(file.path);
      final storagePath = '$basePath/image_${i + 1}.$extension';

      final result = await uploadImage(storagePath: storagePath, file: file);

      result.fold(
        (error) => errors.add('Image ${i + 1}: ${error.message}'),
        (url) => downloadUrls.add(url),
      );
    }

    if (downloadUrls.isEmpty && errors.isNotEmpty) {
      return Left(
        ErrorModel(
          message: 'No se pudo subir ninguna imagen: ${errors.join(', ')}',
          errorCode: 'ALL_UPLOADS_FAILED',
        ),
      );
    }

    return Right(downloadUrls);
  }

  /// Gets the file extension from a path.
  String _getExtension(String path) {
    final parts = path.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : 'jpg';
  }

  /// Determines the content type based on file extension.
  String _getContentType(String path) {
    final extension = _getExtension(path);
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Translates Firebase error codes to user-friendly messages.
  String _getFirebaseAuthErrorMessage(String? code, String? rawMessage) {
    // Check for known error patterns in the raw message
    if (rawMessage != null) {
      if (rawMessage.contains('CONFIGURATION_NOT_FOUND')) {
        return 'El servicio de almacenamiento no está disponible temporalmente. Por favor, intenta nuevamente.';
      }
      if (rawMessage.contains('network')) {
        return 'Error de conexión. Verifica tu conexión a internet e intenta nuevamente.';
      }
    }

    // Handle specific error codes
    switch (code) {
      case 'invalid-custom-token':
        return 'Sesión expirada. Por favor, inicia sesión nuevamente.';
      case 'custom-token-mismatch':
        return 'Error de autenticación. Por favor, inicia sesión nuevamente.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu conexión a internet.';
      case 'too-many-requests':
        return 'Demasiados intentos. Por favor, espera un momento.';
      default:
        return 'No se pudo conectar al servicio. Intenta nuevamente más tarde.';
    }
  }

  /// Translates Firebase Storage error codes to user-friendly messages.
  String _getStorageErrorMessage(String? code, String? rawMessage) {
    // Check for known error patterns
    if (rawMessage != null) {
      if (rawMessage.contains('CONFIGURATION_NOT_FOUND')) {
        return 'El servicio de almacenamiento no está disponible. Intenta nuevamente más tarde.';
      }
      if (rawMessage.contains('timed out') || rawMessage.contains('timeout')) {
        return 'La subida de imagen tardó demasiado. Intenta con una imagen más pequeña.';
      }
    }

    // Handle specific error codes
    switch (code) {
      case 'storage/unauthorized':
        return 'No tienes permiso para subir esta imagen. Inicia sesión nuevamente.';
      case 'storage/canceled':
        return 'La subida fue cancelada.';
      case 'storage/unknown':
        return 'Error al subir la imagen. Intenta nuevamente.';
      case 'storage/object-not-found':
        return 'La imagen no fue encontrada.';
      case 'storage/quota-exceeded':
        return 'Límite de almacenamiento alcanzado. Contacta soporte.';
      case 'storage/retry-limit-exceeded':
        return 'La subida falló. Verifica tu conexión e intenta nuevamente.';
      default:
        return 'No se pudo subir la imagen. Intenta nuevamente.';
    }
  }
}
