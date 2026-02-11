import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/services/mapbox_directions_service.dart';
import 'package:motogo_frontend/src/core/config/secrets.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/constants/person_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/location_service.dart';
import 'package:motogo_frontend/src/features/branch_detail/presentation/pages/branch_detail_page.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/pages/change_password_page.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/usecases/delete_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/pages/edit_profile_page.dart';
import 'package:motogo_frontend/src/features/legal/presentation/pages/legal_page.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/presentation/pages/my_motorcycles_page.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/pages/register_motorcycle_page.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/bloc/user_home_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// User Home Page - Main screen for MOTORCYCLIST users.
///
/// Displays an interactive map with nearby workshops and stores,
/// user location, and promotional content for first-time users.
class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectorApp.resolve<UserHomeBloc>()..add(const InitializeMap()),
      child: const _UserHomeView(),
    );
  }
}

class _UserHomeView extends StatefulWidget {
  const _UserHomeView();

  @override
  State<_UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<_UserHomeView> {
  MapboxMap? _mapController;
  PointAnnotationManager? _annotationManager;
  Timer? _radiusDebounceTimer;
  double _sliderRadius = 5.0;
  Cancelable? _tapListener;
  final Map<String, String> _annotationToBranch = {};
  Uint8List? _workshopMarkerBytes;
  Uint8List? _storeMarkerBytes;
  bool _hasInitiallyCentered = false;
  bool _hasShownDisclaimer = false;

  // In-app navigation state
  bool _isNavigating = false;
  bool _isLoadingRoute = false;
  bool _isImmersiveMode = false;
  DirectionsResult? _activeRoute;
  BranchMarkerEntity? _navigationTarget;
  StreamSubscription<dynamic>? _navigationLocationSub;
  double? _liveDistanceKm;
  double? _liveDurationMin;

  @override
  void initState() {
    super.initState();
    if (Secrets.isMapboxConfigured) {
      MapboxOptions.setAccessToken(Secrets.mapboxAccessToken);
    }
  }

  @override
  void dispose() {
    _radiusDebounceTimer?.cancel();
    _tapListener?.cancel();
    _navigationLocationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          MotorcycleConstants.searchPlaceholder,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      drawer: _buildDrawer(context),
      body: BlocConsumer<UserHomeBloc, UserHomeState>(
        listener: (context, state) {
          if (state is UserHomeLoaded && state.hasUserLocation) {
            // Only auto-center on the very first load
            if (!_hasInitiallyCentered) {
              _hasInitiallyCentered = true;
              _centerOnUser(state.userLatitude!, state.userLongitude!);
            }
          }
          if (state is UserHomeLoaded) {
            _updateMarkers(state.branches);
            // Show error message if present
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
          if (state is UserHomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildMap(state),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildFilterChips(context, state),
              ),
              if (state is UserHomeLoaded && state.locationPermissionDenied)
                Positioned(
                  top: 70,
                  left: 16,
                  right: 16,
                  child: _buildLocationPermissionBanner(),
                ),
              // Radio slider - compact on right side
              Positioned(
                top: state is UserHomeLoaded && state.locationPermissionDenied
                    ? 130
                    : 70,
                right: 16,
                child: _buildRadiusSlider(context, state),
              ),
              if (state is UserHomeLoaded &&
                  state.selectedBranch != null &&
                  !_isNavigating)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: _buildBranchCard(state.selectedBranch!),
                ),
              // Navigation bottom sheet
              if (_isNavigating || _isLoadingRoute)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildNavigationSheet(),
                ),
              // FABs column: Add motorcycle + My location
              Positioned(
                bottom: 24,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add motorcycle FAB - always visible for multiple motorcycles
                    FloatingActionButton(
                      heroTag: 'add_motorcycle',
                      onPressed: () => _navigateToRegisterMotorcycle(context),
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 12),
                    // My location FAB
                    FloatingActionButton(
                      heroTag: 'my_location',
                      onPressed: () => _onLocationFabPressed(context),
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToRegisterMotorcycle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterMotorcyclePage()),
    );
  }

  Widget _buildMap(UserHomeState state) {
    if (!Secrets.isMapboxConfigured) {
      return _buildMapPlaceholder('Token de Mapbox no configurado');
    }

    // Default: Bogotá, Colombia
    double initialLat = 4.60971;
    double initialLng = -74.08175;

    if (state is UserHomeLoaded && state.hasUserLocation) {
      initialLat = state.userLatitude!;
      initialLng = state.userLongitude!;
    }

    return MapWidget(
      key: const ValueKey('user-home-map'),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(initialLng, initialLat)),
        zoom: 14.0,
      ),
      onMapCreated: (controller) => _onMapCreated(controller, state),
      onTapListener: _onMapTap,
    );
  }

  void _onMapCreated(MapboxMap mapController, UserHomeState state) async {
    _mapController = mapController;
    _annotationManager = await mapController.annotations
        .createPointAnnotationManager();
    if (!mounted) return;

    final currentState = context.read<UserHomeBloc>().state;
    if (currentState is UserHomeLoaded) {
      _updateMarkers(currentState.branches);
    }

    // Enable location puck (blue dot for user location)
    await mapController.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
      ),
    );

    // Center on user location if available
    if (state is UserHomeLoaded && state.hasUserLocation) {
      await mapController.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(state.userLongitude!, state.userLatitude!),
          ),
          zoom: 14.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }

    // Show navigation disclaimer on first map load
    if (!_hasShownDisclaimer) {
      _hasShownDisclaimer = true;
      if (mounted) {
        _showNavigationDisclaimer();
      }
    }
  }

  void _showNavigationDisclaimer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                CommonConstants.navigationDisclaimerTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          CommonConstants.navigationDisclaimerBody,
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                CommonConstants.navigationDisclaimerAccept,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapTap(MapContentGestureContext context) {
    this.context.read<UserHomeBloc>().add(const ClearBranchSelection());
  }

  Widget _buildMapPlaceholder(String message) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionBanner() {
    return Card(
      color: Colors.orange[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Activa tu ubicación para ver talleres cercanos',
                style: TextStyle(color: Colors.orange[900]),
              ),
            ),
            TextButton(
              onPressed: () => LocationService.instance.openAppSettings(),
              child: const Text('Activar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusSlider(BuildContext context, UserHomeState state) {
    double currentRadius = _sliderRadius;
    bool isLoading = false;

    if (state is UserHomeLoaded) {
      isLoading = state.isLoadingBranches;
      // Only sync slider with state when NOT loading AND no debounce timer is active
      // This prevents resetting the slider while user is actively changing it
      final hasActiveDebounce = _radiusDebounceTimer?.isActive ?? false;
      if (!isLoading &&
          !hasActiveDebounce &&
          _sliderRadius != state.currentRadiusKm) {
        currentRadius = state.currentRadiusKm;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _sliderRadius = currentRadius);
        });
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Minus button
            _buildRadiusButton(
              icon: Icons.remove,
              onPressed: _sliderRadius > 1
                  ? () => _changeRadius(context, _sliderRadius - 1)
                  : null,
            ),
            // Radius display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: isLoading
                  ? const SizedBox(
                      width: 40,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '${_sliderRadius.round()} km',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                        fontSize: 14,
                      ),
                    ),
            ),
            // Plus button
            _buildRadiusButton(
              icon: Icons.add,
              onPressed: _sliderRadius < 50
                  ? () => _changeRadius(context, _sliderRadius + 1)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusButton({required IconData icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: onPressed != null ? Colors.blue[50] : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: onPressed != null ? Colors.blue[700] : Colors.grey,
        ),
      ),
    );
  }

  void _changeRadius(BuildContext context, double newRadius) {
    setState(() => _sliderRadius = newRadius.clamp(1.0, 50.0));

    // Sync map zoom with radius
    _adjustZoomForRadius(_sliderRadius);

    _radiusDebounceTimer?.cancel();
    _radiusDebounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => context.read<UserHomeBloc>().add(ChangeRadius(_sliderRadius)),
    );
  }

  /// Adjusts the map zoom level to match the search radius.
  /// Smaller radius → zoom in, larger radius → zoom out.
  Future<void> _adjustZoomForRadius(double radiusKm) async {
    if (_mapController == null) return;

    // Logarithmic mapping: 1km→16, 5km→14, 10km→13, 25km→11, 50km→9.5
    final zoom = 16.0 - 1.66 * (math.log(radiusKm.clamp(1, 50)) / math.ln2);

    // Preserve the current camera center so the map doesn't jump
    final currentCamera = await _mapController!.getCameraState();

    _mapController!.flyTo(
      CameraOptions(center: currentCamera.center, zoom: zoom.clamp(9.0, 16.0)),
      MapAnimationOptions(duration: 400),
    );
  }

  Widget _buildFilterChips(BuildContext context, UserHomeState state) {
    final filters = [
      (MotorcycleConstants.filterAll, null),
      (MotorcycleConstants.filterWorkshop, 'taller'),
      (MotorcycleConstants.filterStore, 'tienda'),
    ];

    String? activeFilter;
    if (state is UserHomeLoaded) {
      activeFilter = state.activeTypeFilter;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected =
              filter.$2 == activeFilter ||
              (filter.$2 == null && activeFilter == null);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.$1),
              selected: isSelected,
              onSelected: (selected) {
                context.read<UserHomeBloc>().add(ChangeTypeFilter(filter.$2));
              },
              selectedColor: Colors.blue[600],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              elevation: 2,
              shadowColor: Colors.black26,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBranchCard(BranchMarkerEntity branch) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: branch.isWorkshop || branch.isWorkshopStore
                        ? Colors.orange[50]
                        : Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    branch.isWorkshop || branch.isWorkshopStore
                        ? Icons.build
                        : Icons.store,
                    color: branch.isWorkshop || branch.isWorkshopStore
                        ? Colors.orange[600]
                        : Colors.green[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (branch.address != null)
                        Text(
                          branch.address!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (branch.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(branch.rating!.toStringAsFixed(1)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: branch.isWorkshop || branch.isWorkshopStore
                        ? Colors.orange[100]
                        : Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    branch.displayTypeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: branch.isWorkshop || branch.isWorkshopStore
                          ? Colors.orange[800]
                          : Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (branch.distanceKm != null)
                  Text(
                    '${branch.distanceKm!.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _navigateToBranchDetail(context, branch),
                  child: const Text(CommonConstants.seeMore),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: OutlinedButton.icon(
                    onPressed: () => _startNavigation(context, branch),
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text(
                      CommonConstants.howToGetThere,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBranchDetail(
    BuildContext context,
    BranchMarkerEntity branch,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BranchDetailPage(branchId: branch.id, branchName: branch.name),
      ),
    );
  }

  void _centerOnUser(double lat, double lng) {
    _mapController?.flyTo(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15.0),
      MapAnimationOptions(duration: 1000),
    );
  }

  void _updateMarkers(List<BranchMarkerEntity> branches) async {
    if (_annotationManager == null) return;

    await _annotationManager!.deleteAll();

    // Clear and rebuild annotation to branch mapping
    _annotationToBranch.clear();

    for (final branch in branches) {
      // Color by type: workshop=blue, store=green
      final markerBytes = await _getMarkerBytes(branch.isWorkshop);

      final options = PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(branch.longitude, branch.latitude),
        ),
        image: markerBytes,
        iconSize: 1.0,
        // No text - just icon. Card shows on tap.
      );

      final annotation = await _annotationManager!.create(options);
      _annotationToBranch[annotation.id] = branch.id;
    }

    // Set up tap listener using new tapEvents API
    _tapListener?.cancel();
    _tapListener = _annotationManager!.tapEvents(
      onTap: (annotation) {
        final branchId = _annotationToBranch[annotation.id];
        if (branchId != null && mounted) {
          context.read<UserHomeBloc>().add(SelectBranch(branchId));
        }
      },
    );
  }

  Future<Uint8List> _getMarkerBytes(bool isWorkshop) async {
    if (isWorkshop && _workshopMarkerBytes != null) {
      return _workshopMarkerBytes!;
    }
    if (!isWorkshop && _storeMarkerBytes != null) {
      return _storeMarkerBytes!;
    }

    final assetPath = isWorkshop
        ? 'assets/icons/motorcycle_blue.png'
        : 'assets/icons/motorcycle_green.png';
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    if (isWorkshop) {
      _workshopMarkerBytes = bytes;
    } else {
      _storeMarkerBytes = bytes;
    }
    return bytes;
  }

  void _onLocationFabPressed(BuildContext context) async {
    final bloc = context.read<UserHomeBloc>();
    final state = bloc.state;

    if (state is UserHomeLoaded && state.hasUserLocation) {
      _centerOnUser(state.userLatitude!, state.userLongitude!);
    } else {
      bloc.add(const InitializeMap());
    }
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(Config.googleMapsDirectionsUrl(lat, lng));
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // --------------- In-App Navigation ---------------

  Future<void> _startNavigation(
    BuildContext context,
    BranchMarkerEntity branch,
  ) async {
    final bloc = context.read<UserHomeBloc>();
    final state = bloc.state;

    if (state is! UserHomeLoaded || !state.hasUserLocation) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(CommonConstants.noLocationForNavigation),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _navigationTarget = branch;
    });

    final result = await MapboxDirectionsService.getRoute(
      originLat: state.userLatitude!,
      originLng: state.userLongitude!,
      destLat: branch.latitude,
      destLng: branch.longitude,
    );

    if (!mounted) return;

    if (result == null) {
      setState(() => _isLoadingRoute = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(CommonConstants.routeError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoadingRoute = false;
      _isNavigating = true;
      _activeRoute = result;
      _liveDistanceKm = result.distanceKm;
      _liveDurationMin = result.durationMin;
    });

    await _drawRouteOnMap(result);
    await _fitRouteInView(result);
  }

  /// Activates immersive close-up tracking mode when user taps "Comenzar".
  void _beginImmersiveTracking() {
    setState(() => _isImmersiveMode = true);
    _startLiveTracking();
  }

  void _startLiveTracking() {
    _navigationLocationSub?.cancel();
    _navigationLocationSub = LocationService.instance
        .getPositionStream(distanceFilter: 10)
        .listen(_onNavigationPositionUpdate);
  }

  void _onNavigationPositionUpdate(dynamic position) {
    if (!_isNavigating || _navigationTarget == null || !mounted) return;

    final userLat = position.latitude as double;
    final userLng = position.longitude as double;
    final destLat = _navigationTarget!.latitude;
    final destLng = _navigationTarget!.longitude;

    // Calculate remaining distance
    final remainingKm = _haversineDistance(userLat, userLng, destLat, destLng);

    // Estimate remaining time (assume avg speed from original route)
    final avgSpeedKmPerMin =
        _activeRoute != null && _activeRoute!.durationMin > 0
        ? _activeRoute!.distanceKm / _activeRoute!.durationMin
        : 0.5; // fallback: 30 km/h
    final remainingMin = avgSpeedKmPerMin > 0
        ? remainingKm / avgSpeedKmPerMin
        : remainingKm * 2;

    setState(() {
      _liveDistanceKm = remainingKm;
      _liveDurationMin = remainingMin;
    });

    // Calculate bearing toward destination
    final bearing = _calculateBearing(userLat, userLng, destLat, destLng);

    // Follow user with camera (immersive close-up)
    _mapController?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(userLng, userLat)),
        zoom: 17.5,
        bearing: bearing,
        pitch: 60.0,
      ),
      MapAnimationOptions(duration: 800),
    );

    // Check if user arrived (within 50m)
    if (remainingKm < 0.05) {
      _clearRoute();
    }
  }

  /// Haversine formula to calculate distance between two points in km.
  double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculate bearing from point 1 to point 2 in degrees.
  double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    final dLng = _toRadians(lng2 - lng1);
    final y = math.sin(dLng) * math.cos(_toRadians(lat2));
    final x =
        math.cos(_toRadians(lat1)) * math.sin(_toRadians(lat2)) -
        math.sin(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.cos(dLng);
    return (_toDegrees(math.atan2(y, x)) + 360) % 360;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _toDegrees(double radians) => radians * 180 / math.pi;

  Future<void> _drawRouteOnMap(DirectionsResult route) async {
    if (_mapController == null) return;

    final style = _mapController!.style;

    // Build GeoJSON LineString
    final geoJson = json.encode({
      'type': 'Feature',
      'geometry': {'type': 'LineString', 'coordinates': route.coordinates},
    });

    // Remove previous route if exists
    try {
      await style.removeStyleLayer('route-layer');
      await style.removeStyleSource('route-source');
    } catch (_) {
      // Layer/source might not exist yet
    }

    // Add source and layer
    await style.addSource(GeoJsonSource(id: 'route-source', data: geoJson));

    await style.addLayer(
      LineLayer(
        id: 'route-layer',
        sourceId: 'route-source',
        lineColor: Colors.blue.value,
        lineWidth: 5.0,
        lineCap: LineCap.ROUND,
        lineJoin: LineJoin.ROUND,
      ),
    );

    // Add direction arrows along the route
    await _addRouteArrows(style);
  }

  /// Adds white arrow symbols along the route line for direction guidance.
  Future<void> _addRouteArrows(StyleManager style) async {
    try {
      // Remove previous arrows
      try {
        await style.removeStyleLayer('route-arrows');
      } catch (_) {}

      // Add text-based arrow symbols along the route line
      await style.addLayer(
        SymbolLayer(
          id: 'route-arrows',
          sourceId: 'route-source',
          symbolPlacement: SymbolPlacement.LINE,
          symbolSpacing: 80.0,
          textField: '▶',
          textSize: 16.0,
          textColor: Colors.white.value,
          textAllowOverlap: true,
          textIgnorePlacement: true,
          textRotationAlignment: TextRotationAlignment.MAP,
        ),
      );
    } catch (e) {
      // Arrow layer is optional — route still works without it
      debugPrint('Could not add route arrows: $e');
    }
  }

  Future<void> _fitRouteInView(DirectionsResult route) async {
    if (_mapController == null || route.coordinates.isEmpty) return;

    double minLng = route.coordinates[0][0];
    double maxLng = route.coordinates[0][0];
    double minLat = route.coordinates[0][1];
    double maxLat = route.coordinates[0][1];

    for (final coord in route.coordinates) {
      if (coord[0] < minLng) minLng = coord[0];
      if (coord[0] > maxLng) maxLng = coord[0];
      if (coord[1] < minLat) minLat = coord[1];
      if (coord[1] > maxLat) maxLat = coord[1];
    }

    await _mapController!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position((minLng + maxLng) / 2, (minLat + maxLat) / 2),
        ),
        // Calculate a zoom that fits the route
        zoom: _calculateZoomForBounds(minLat, maxLat, minLng, maxLng),
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  double _calculateZoomForBounds(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) {
    final latDiff = (maxLat - minLat).abs();
    final lngDiff = (maxLng - minLng).abs();
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff < 0.005) return 16.0;
    if (maxDiff < 0.01) return 15.0;
    if (maxDiff < 0.02) return 14.0;
    if (maxDiff < 0.05) return 13.0;
    if (maxDiff < 0.1) return 12.0;
    if (maxDiff < 0.2) return 11.0;
    if (maxDiff < 0.5) return 10.0;
    return 9.0;
  }

  Future<void> _clearRoute() async {
    // Stop live tracking
    _navigationLocationSub?.cancel();
    _navigationLocationSub = null;

    if (_mapController != null) {
      try {
        await _mapController!.style.removeStyleLayer('route-arrows');
        await _mapController!.style.removeStyleLayer('route-layer');
        await _mapController!.style.removeStyleSource('route-source');
      } catch (_) {}

      // Reset camera pitch/bearing
      await _mapController!.flyTo(
        CameraOptions(pitch: 0, bearing: 0),
        MapAnimationOptions(duration: 500),
      );
    }

    setState(() {
      _isNavigating = false;
      _isLoadingRoute = false;
      _isImmersiveMode = false;
      _activeRoute = null;
      _navigationTarget = null;
      _liveDistanceKm = null;
      _liveDurationMin = null;
    });
  }

  Widget _buildNavigationSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: _isLoadingRoute
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(CommonConstants.loadingRoute),
                ],
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Branch name + route info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.directions, color: Colors.blue[600]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _navigationTarget?.name ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (_activeRoute != null)
                            Text(
                              '${(_liveDistanceKm ?? _activeRoute!.distanceKm).toStringAsFixed(1)} km · '
                              '${(_liveDurationMin ?? _activeRoute!.durationMin).round()} ${CommonConstants.estimatedTime}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Action buttons — layout depends on immersive mode
                if (!_isImmersiveMode && _activeRoute != null) ...[
                  // "Comenzar" full-width button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _beginImmersiveTracking,
                      icon: const Icon(Icons.navigation_rounded, size: 20),
                      label: const Text(
                        CommonConstants.startNavigation,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Cancel + Google Maps row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearRoute,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text(CommonConstants.cancelRoute),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _navigationTarget != null
                              ? () => _openGoogleMaps(
                                  _navigationTarget!.latitude,
                                  _navigationTarget!.longitude,
                                )
                              : null,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text(
                            CommonConstants.openInGoogleMaps,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue[600],
                            side: BorderSide(color: Colors.blue[600]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Immersive mode: Cancel + Google Maps
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearRoute,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text(CommonConstants.cancelRoute),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _navigationTarget != null
                              ? () => _openGoogleMaps(
                                  _navigationTarget!.latitude,
                                  _navigationTarget!.longitude,
                                )
                              : null,
                          icon: const Icon(Icons.map, size: 18),
                          label: const Text(
                            CommonConstants.openInGoogleMaps,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  void _navigateToLegal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LegalPage()),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.account_circle, size: 60, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  MotorcycleConstants.drawerTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text(
              MotorcycleConstants.menuHome,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text(
              MotorcycleConstants.menuEditProfile,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditMyProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.two_wheeler, color: Colors.blue),
            title: const Text(
              MotorcycleConstants.menuMyMotorcycle,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyMotorcyclesPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.blue),
            title: const Text(
              MotorcycleConstants.menuChangePassword,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) =>
                        InjectorApp.resolve<ChangePasswordBloc>(),
                    child: const ChangePasswordPage(),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              MotorcycleConstants.menuDeleteAccount,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAccountDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.blue),
            title: const Text(
              MotorcycleConstants.menuLogout,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blue),
            title: const Text(
              MotorcycleConstants.menuAbout,
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              _navigateToLegal(context);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final confirmController = TextEditingController();
    bool isConfirmValid = false;
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      PersonConstants.deleteAccountTitle,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    PersonConstants.deleteAccountWarning,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    PersonConstants.deleteAccountConfirmPrompt,
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmController,
                    enabled: !isDeleting,
                    decoration: InputDecoration(
                      hintText: PersonConstants.deleteAccountConfirmWord,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        isConfirmValid =
                            value.toLowerCase().trim() ==
                            PersonConstants.deleteAccountConfirmWord;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(CommonConstants.cancel),
                ),
                TextButton(
                  onPressed: (!isConfirmValid || isDeleting)
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          final deleteUseCase =
                              InjectorApp.resolve<DeletePersonUseCase>();
                          final result = await deleteUseCase();
                          result.fold(
                            (error) {
                              setDialogState(() => isDeleting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                            (message) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              context.read<EditProfileBloc>().add(
                                const EditProfileReset(),
                              );
                              context.read<LoginBloc>().add(LoginLogout());
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            },
                          );
                        },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: isDeleting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(PersonConstants.deleteAccountButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginLoggedOut) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: const Text(MotorcycleConstants.confirmLogoutTitle),
              content: const Text(MotorcycleConstants.confirmLogoutMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(CommonConstants.cancel),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.read<EditProfileBloc>().add(
                      const EditProfileReset(),
                    );
                    context.read<LoginBloc>().add(LoginLogout());
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text(MotorcycleConstants.menuLogout),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
