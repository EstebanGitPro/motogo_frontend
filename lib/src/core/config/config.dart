class Config {
  static const String baseUrl =
      'https://d54tmr5b-8085.use2.devtunnels.ms/motogo/api/v1';

  /// URL de navegación de Google Maps con destino específico
  static String googleMapsDirectionsUrl(double lat, double lng) =>
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
}
