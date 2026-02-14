import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:motogo_frontend/src/core/config/secrets.dart';
import 'package:motogo_frontend/src/core/utils/app_logger.dart';

/// Result of a Mapbox Directions API request.
class DirectionsResult {
  /// Route coordinates as [lng, lat] pairs for GeoJSON.
  final List<List<double>> coordinates;

  /// Total distance in kilometers.
  final double distanceKm;

  /// Estimated duration in minutes.
  final double durationMin;

  const DirectionsResult({
    required this.coordinates,
    required this.distanceKm,
    required this.durationMin,
  });
}

/// Service that calls the Mapbox Directions API to get driving routes.
class MapboxDirectionsService {
  static const String _baseUrl =
      'https://api.mapbox.com/directions/v5/mapbox/driving';

  /// Fetches a driving route between [originLng],[originLat] and
  /// [destLng],[destLat].
  ///
  /// Returns a [DirectionsResult] with the route geometry, distance,
  /// and estimated duration. Returns `null` if the request fails.
  static Future<DirectionsResult?> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    const token = Secrets.mapboxAccessToken;
    if (token.isEmpty) {
      AppLogger.error('Mapbox access token is not configured');
      return null;
    }

    final url = Uri.parse(
      '$_baseUrl/$originLng,$originLat;$destLng,$destLat'
      '?geometries=geojson&overview=full&access_token=$token',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        AppLogger.error('Mapbox Directions API error: ${response.statusCode}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>?;

      if (routes == null || routes.isEmpty) {
        AppLogger.error('No routes found');
        return null;
      }

      final route = routes[0] as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final rawCoords = geometry['coordinates'] as List<dynamic>;

      final coordinates = rawCoords
          .map((c) => [(c as List)[0] as double, c[1] as double])
          .toList();

      // API returns distance in meters, duration in seconds
      final distanceMeters = (route['distance'] as num).toDouble();
      final durationSeconds = (route['duration'] as num).toDouble();

      return DirectionsResult(
        coordinates: coordinates,
        distanceKm: distanceMeters / 1000.0,
        durationMin: durationSeconds / 60.0,
      );
    } catch (e) {
      AppLogger.error('Error fetching directions: $e');
      return null;
    }
  }
}
