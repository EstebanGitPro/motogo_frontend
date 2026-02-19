import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/config/secrets.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/location_service.dart';
import 'package:motogo_frontend/src/core/services/mapbox_directions_service.dart';
import 'package:motogo_frontend/src/core/utils/app_logger.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/user_home_drawer.dart';
import 'package:motogo_frontend/src/features/branch_detail/presentation/pages/branch_detail_page.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/pages/register_motorcycle_page.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/bloc/user_home_bloc.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/branch_card.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/filter_bottom_sheet.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/navigation_bottom_sheet.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/search_result_card.dart';
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

  // Search state
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // In-app navigation state
  bool _isNavigating = false;
  bool _isLoadingRoute = false;
  bool _isImmersiveMode = false;
  DirectionsResult? _activeRoute;
  BranchMarkerEntity? _navigationTarget;
  StreamSubscription<dynamic>? _navigationLocationSub;
  double? _liveDistanceKm;
  double? _liveDurationMin;

  // Mapbox style layer/source IDs (avoids duplicated literals)
  static const _routeLayerId = 'route-layer';
  static const _routeSourceId = 'route-source';
  static const _routeArrowsId = 'route-arrows';

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: MotorcycleConstants.searchPlaceholder,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                onChanged: (query) {
                  context.read<UserHomeBloc>().add(SearchBranches(query));
                },
              )
            : GestureDetector(
                onTap: () => setState(() => _isSearching = true),
                child: Text(
                  MotorcycleConstants.searchPlaceholder,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
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
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: MotorcycleConstants.searchClearTooltip,
              onPressed: () {
                _searchController.clear();
                context.read<UserHomeBloc>().add(const SearchBranches(''));
                setState(() => _isSearching = false);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
        ],
      ),
      drawer: const UserHomeDrawer(),
      body: BlocConsumer<UserHomeBloc, UserHomeState>(
        listener: _handleStateChange,
        builder: (context, state) {
          final showPermissionBanner =
              state is UserHomeLoaded && state.locationPermissionDenied;
          return Stack(
            children: [
              _buildMap(state),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildFilterChips(context, state),
              ),
              if (showPermissionBanner)
                Positioned(
                  top: 70,
                  left: 16,
                  right: 16,
                  child: _buildLocationPermissionBanner(),
                ),
              Positioned(
                top: showPermissionBanner ? 130 : 70,
                right: 16,
                child: _buildRadiusSlider(context, state),
              ),
              ..._buildSelectedBranchCard(context, state),
              ..._buildNavigationSheet(),
              _buildFabColumn(context),
              // Search results overlay
              if (state is UserHomeLoaded && state.searchQuery.isNotEmpty)
                _buildSearchOverlay(context, state),
            ],
          );
        },
      ),
    );
  }

  void _handleStateChange(BuildContext context, UserHomeState state) {
    if (state is UserHomeLoaded &&
        state.hasUserLocation &&
        !_hasInitiallyCentered) {
      _hasInitiallyCentered = true;
      _centerOnUser(state.userLatitude!, state.userLongitude!);
    }
    if (state is UserHomeLoaded) {
      _updateMarkers(state.branches);
      _showErrorIfPresent(context, state.errorMessage);
    }
    if (state is UserHomeError) {
      _showErrorSnackBar(context, state.message);
    }
  }

  void _showErrorIfPresent(BuildContext context, String? errorMessage) {
    if (errorMessage == null) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
  }

  List<Widget> _buildSelectedBranchCard(
    BuildContext context,
    UserHomeState state,
  ) {
    if (state is! UserHomeLoaded ||
        state.selectedBranch == null ||
        _isNavigating) {
      return const [];
    }
    return [
      Positioned(
        bottom: 100,
        left: 16,
        right: 16,
        child: BranchCard(
          branch: state.selectedBranch!,
          onSeeMore: () =>
              _navigateToBranchDetail(context, state.selectedBranch!),
          onNavigate: () => _startNavigation(context, state.selectedBranch!),
        ),
      ),
    ];
  }

  List<Widget> _buildNavigationSheet() {
    if (!_isNavigating && !_isLoadingRoute) return const [];
    return [
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: NavigationBottomSheet(
          isLoadingRoute: _isLoadingRoute,
          isImmersiveMode: _isImmersiveMode,
          navigationTarget: _navigationTarget,
          activeDistanceKm: _activeRoute?.distanceKm,
          activeDurationMin: _activeRoute?.durationMin,
          liveDistanceKm: _liveDistanceKm,
          liveDurationMin: _liveDurationMin,
          onBeginImmersive: _beginImmersiveTracking,
          onCancelRoute: _clearRoute,
          onOpenGoogleMaps: _navigationTarget != null
              ? () => _openGoogleMaps(
                  _navigationTarget!.latitude,
                  _navigationTarget!.longitude,
                )
              : null,
        ),
      ),
    ];
  }

  Widget _buildFabColumn(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_motorcycle',
            onPressed: () => _navigateToRegisterMotorcycle(context),
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'my_location',
            onPressed: () => _onLocationFabPressed(context),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay(BuildContext context, UserHomeLoaded state) {
    final results = state.searchResults;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          _searchController.clear();
          context.read<UserHomeBloc>().add(const SearchBranches(''));
          setState(() => _isSearching = false);
        },
        behavior: HitTestBehavior.translucent,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: results.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          MotorcycleConstants.searchNoResults,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: results.length,
                      itemBuilder: (_, index) => SearchResultCard(
                        branch: results[index],
                        onTap: () =>
                            _onSearchResultTap(context, results[index]),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _onSearchResultTap(BuildContext context, BranchMarkerEntity branch) {
    // Clear search
    _searchController.clear();
    context.read<UserHomeBloc>().add(const SearchBranches(''));
    setState(() => _isSearching = false);

    // Select branch and center map
    context.read<UserHomeBloc>().add(SelectBranch(branch.id));
    _mapController?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(branch.longitude, branch.latitude)),
        zoom: 16.0,
      ),
      MapAnimationOptions(duration: 1000),
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
                CommonConstants.locationPermissionBanner,
                style: TextStyle(color: Colors.orange[900]),
              ),
            ),
            TextButton(
              onPressed: () => LocationService.instance.openAppSettings(),
              child: const Text(CommonConstants.activate),
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
    String? activeBrand;
    String? activeDisplacement;
    if (state is UserHomeLoaded) {
      activeFilter = state.activeTypeFilter;
      activeBrand = state.activeBrandFilter;
      activeDisplacement = state.activeDisplacementRangeFilter;
    }

    // Count active advanced filters
    int advancedFilterCount = 0;
    if (activeBrand != null) advancedFilterCount++;
    if (activeDisplacement != null) advancedFilterCount++;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...filters.map((filter) {
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
          }),
          // Filter button with badge
          ActionChip(
            avatar: Badge(
              isLabelVisible: advancedFilterCount > 0,
              label: Text(
                '$advancedFilterCount',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor: Colors.orange,
              child: Icon(
                Icons.tune,
                size: 18,
                color: advancedFilterCount > 0
                    ? Colors.blue[700]
                    : Colors.grey[700],
              ),
            ),
            label: Text(
              MotorcycleConstants.filterButton,
              style: TextStyle(
                color: advancedFilterCount > 0
                    ? Colors.blue[700]
                    : Colors.black87,
                fontWeight: advancedFilterCount > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onPressed: () => _showFilterBottomSheet(
              context,
              activeBrand,
              activeDisplacement,
            ),
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.black26,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    String? currentBrand,
    String? currentDisplacement,
  ) {
    final bloc = context.read<UserHomeBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        currentBrand: currentBrand,
        currentDisplacementRange: currentDisplacement,
        onApply: (brand, displacement) {
          bloc.add(
            ApplyAdvancedFilters(brand: brand, displacementRange: displacement),
          );
        },
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
    // Capture ScaffoldMessenger before async gap to avoid BuildContext usage
    // across async boundaries.
    final messenger = ScaffoldMessenger.of(context);

    if (state is! UserHomeLoaded || !state.hasUserLocation) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(CommonConstants.noLocationForNavigation),
            backgroundColor: Colors.orange,
          ),
        );
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
      messenger
        ..clearSnackBars()
        ..showSnackBar(
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
      await style.removeStyleLayer(_routeLayerId);
      await style.removeStyleSource(_routeSourceId);
    } catch (_) {
      // Layer/source might not exist yet
    }

    // Add source and layer
    await style.addSource(GeoJsonSource(id: _routeSourceId, data: geoJson));

    await style.addLayer(
      LineLayer(
        id: _routeLayerId,
        sourceId: _routeSourceId,
        lineColor: Colors.blue.toARGB32(),
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
        await style.removeStyleLayer(_routeArrowsId);
      } catch (_) {}

      // Add text-based arrow symbols along the route line
      await style.addLayer(
        SymbolLayer(
          id: _routeArrowsId,
          sourceId: _routeSourceId,
          symbolPlacement: SymbolPlacement.LINE,
          symbolSpacing: 80.0,
          textField: '▶',
          textSize: 16.0,
          textColor: Colors.white.toARGB32(),
          textAllowOverlap: true,
          textIgnorePlacement: true,
          textRotationAlignment: TextRotationAlignment.MAP,
        ),
      );
    } catch (e) {
      // Arrow layer is optional — route still works without it
      AppLogger.error('Could not add route arrows: $e');
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
        await _mapController!.style.removeStyleLayer(_routeArrowsId);
        await _mapController!.style.removeStyleLayer(_routeLayerId);
        await _mapController!.style.removeStyleSource(_routeSourceId);
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
}
