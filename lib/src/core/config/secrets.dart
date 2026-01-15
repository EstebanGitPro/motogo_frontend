/// Centralized secrets configuration.
///
/// All secrets are loaded from environment variables using --dart-define
/// at build time. This ensures secrets are never committed to version control.
///
/// Usage:
/// ```bash
/// flutter run --dart-define=MAPBOX_ACCESS_TOKEN=pk.xxx
/// ```
///
/// Or with the run script:
/// ```bash
/// ./scripts/run_dev.sh
/// ```
class Secrets {
  /// Mapbox access token for maps functionality.
  /// Get your token from https://account.mapbox.com/access-tokens/
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  /// Returns true if Mapbox is configured with a valid token.
  static bool get isMapboxConfigured => mapboxAccessToken.isNotEmpty;

  // Add more secrets here as needed:
  // static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
}
