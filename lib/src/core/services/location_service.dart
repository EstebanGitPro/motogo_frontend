import 'dart:async';

import 'package:geolocator/geolocator.dart';

/// Service for handling device location.
///
/// Provides methods to get current position and stream position updates.
/// Handles permission requests automatically.
class LocationService {
  static final LocationService _instance = LocationService._();
  static LocationService get instance => _instance;
  LocationService._();

  StreamSubscription<Position>? _positionSubscription;

  /// Checks if location services are enabled and permission is granted.
  Future<bool> isLocationAvailable() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Requests location permission from the user.
  /// Returns the granted permission level.
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  /// Gets the current device position.
  /// Returns null if permission is denied or location services are disabled.
  Future<Position?> getCurrentPosition() async {
    final permission = await requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Returns a stream of position updates.
  /// Updates are emitted when the device moves more than [distanceFilter] meters.
  Stream<Position> getPositionStream({int distanceFilter = 10}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Starts listening to position updates and calls [onPosition] for each update.
  void startListening({
    required void Function(Position) onPosition,
    int distanceFilter = 10,
  }) {
    _positionSubscription?.cancel();
    _positionSubscription = getPositionStream(
      distanceFilter: distanceFilter,
    ).listen(onPosition);
  }

  /// Stops listening to position updates.
  void stopListening() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Opens the device's location settings.
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }

  /// Opens the app's settings page for permission management.
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }
}
