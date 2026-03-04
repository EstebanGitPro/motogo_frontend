class Config {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8085/motogo/api/v1',
  );

  /// URL de navegación de Google Maps con destino específico
  static String googleMapsDirectionsUrl(double lat, double lng) =>
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';

  /// URL de búsqueda de Google Maps para mostrar ubicación
  static String googleMapsSearchUrl(double lat, double lng) =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
}
