import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/repositories/catalogs_repository.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/config/secrets.dart';
import 'package:motogo_frontend/src/core/constants/branch_constants.dart';
import 'package:motogo_frontend/src/core/geocoding/data/datasources/geocoding_data_source.dart';
import 'package:motogo_frontend/src/core/geocoding/data/models/geocoding_result_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/entities/branch_entity.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tab widget that displays branch location on a Mapbox map.
///
/// Uses the geocoding API to convert the branch address to coordinates,
/// then displays an interactive Mapbox map with a marker.
class BranchLocationTab extends StatefulWidget {
  final BranchEntity branch;

  const BranchLocationTab({super.key, required this.branch});

  @override
  State<BranchLocationTab> createState() => _BranchLocationTabState();
}

class _BranchLocationTabState extends State<BranchLocationTab> {
  bool _isLoading = true;
  GeocodingResultModel? _geocodingResult;
  String? _errorMessage;

  // Resolved names from catalogs (used for display)
  String _cityName = '';
  String _departmentName = '';

  // Mapbox controller
  MapboxMap? _mapboxMap;

  // Annotation manager for cleanup
  CircleAnnotationManager? _circleManager;

  @override
  void initState() {
    super.initState();
    // Configure Mapbox access token from secrets
    MapboxOptions.setAccessToken(Secrets.mapboxAccessToken);
    _loadLocation();
  }

  @override
  void didUpdateWidget(covariant BranchLocationTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload location when branch data changes
    if (oldWidget.branch.address != widget.branch.address ||
        oldWidget.branch.cityId != widget.branch.cityId ||
        oldWidget.branch.departmentId != widget.branch.departmentId) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _geocodingResult = null;
      });
      _loadLocation();
    }
  }

  Future<void> _loadLocation() async {
    // First resolve city and department names if not available
    _cityName = widget.branch.cityName ?? '';
    _departmentName = widget.branch.departmentName ?? '';

    if (_cityName.isEmpty || _departmentName.isEmpty) {
      await _resolveCatalogNames();
    }

    // Now call geocoding API with resolved names
    final geocodingDataSource = InjectorApp.resolve<GeocodingDataSource>();

    final result = await geocodingDataSource.geocode(
      address: widget.branch.address,
      cityName: _cityName,
      departmentName: _departmentName,
    );

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.message;
        });
      },
      (geocodingResult) {
        setState(() {
          _isLoading = false;
          _geocodingResult = geocodingResult;
        });
      },
    );
  }

  Future<void> _resolveCatalogNames() async {
    final catalogsRepo = InjectorApp.resolve<CatalogsRepository>();

    // Get department name
    if (_departmentName.isEmpty && widget.branch.departmentId.isNotEmpty) {
      final deptResult = await catalogsRepo.getDepartments();
      deptResult.fold((_) {}, (departments) {
        final dept = departments
            .where((d) => d.id == widget.branch.departmentId)
            .firstOrNull;
        if (dept != null) {
          _departmentName = dept.name;
        }
      });
    }

    // Get city name
    if (_cityName.isEmpty && widget.branch.cityId.isNotEmpty) {
      final citiesResult = await catalogsRepo.getCitiesByDepartment(
        widget.branch.departmentId,
      );
      citiesResult.fold((_) {}, (cities) {
        final city = cities
            .where((c) => c.id == widget.branch.cityId)
            .firstOrNull;
        if (city != null) {
          _cityName = city.name;
        }
      });
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    if (_geocodingResult != null && _geocodingResult!.isValid) {
      // Add marker at branch location
      await _addMarker();
    }
  }

  Future<void> _addMarker() async {
    if (_mapboxMap == null || _geocodingResult == null) return;

    final lat = _geocodingResult!.latitude;
    final lng = _geocodingResult!.longitude;

    // Clean up existing markers if manager exists
    if (_circleManager != null) {
      await _circleManager!.deleteAll();
    } else {
      // Create circle annotation manager for markers
      _circleManager = await _mapboxMap!.annotations
          .createCircleAnnotationManager();
    }

    // Add a red circle marker at the branch location
    await _circleManager!.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        circleRadius: 12.0,
        circleColor: Colors.red.toARGB32(),
        circleStrokeWidth: 3.0,
        circleStrokeColor: Colors.white.toARGB32(),
      ),
    );

    // Also add a smaller inner dot for better visibility
    await _circleManager!.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        circleRadius: 5.0,
        circleColor: Colors.white.toARGB32(),
      ),
    );

    // Update camera to the new location
    await _mapboxMap!.flyTo(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15.0),
      MapAnimationOptions(duration: 500),
    );
  }

  Future<void> _openInMaps() async {
    if (_geocodingResult == null || !_geocodingResult!.isValid) return;

    final lat = _geocodingResult!.latitude;
    final lng = _geocodingResult!.longitude;
    final url = Uri.parse(Config.googleMapsSearchUrl(lat, lng));

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(BranchConstants.loadingLocation),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_geocodingResult == null || !_geocodingResult!.isValid) {
      return _buildLocationNotAvailable();
    }

    return _buildMapView();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? BranchConstants.errorLoadingLocation,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadLocation();
            },
            icon: const Icon(Icons.refresh),
            label: const Text(BranchConstants.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationNotAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            BranchConstants.locationNotAvailable,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.branch.address,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    final lat = _geocodingResult!.latitude;
    final lng = _geocodingResult!.longitude;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mapbox map container
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapWidget(
                cameraOptions: CameraOptions(
                  center: Point(coordinates: Position(lng, lat)),
                  zoom: 15.0,
                ),
                onMapCreated: _onMapCreated,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Address card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red[400]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _geocodingResult!.formattedAddress.isNotEmpty
                              ? _geocodingResult!.formattedAddress
                              : widget.branch.address,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_cityName.isNotEmpty || _departmentName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      [
                        _cityName,
                        _departmentName,
                      ].where((s) => s.isNotEmpty).join(', '),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Open in Maps button
          ElevatedButton.icon(
            onPressed: _openInMaps,
            icon: const Icon(Icons.map),
            label: const Text(BranchConstants.openInMaps),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
