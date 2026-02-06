import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/config/secrets.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/constants/person_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/services/location_service.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:motogo_frontend/src/features/change_password/presentation/pages/change_password_page.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/usecases/delete_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/pages/edit_profile_page.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/presentation/pages/my_motorcycles_page.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/pages/register_motorcycle_page.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/domain/usecases/get_nearby_branches_usecase.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/bloc/user_home_bloc.dart';
import 'package:motogo_frontend/src/features/branch_detail/presentation/pages/branch_detail_page.dart';
import 'package:motogo_frontend/src/features/legal/presentation/pages/legal_page.dart';
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
      create: (context) => UserHomeBloc(
        getNearbyBranchesUseCase:
            InjectorApp.resolve<GetNearbyBranchesUseCase>(),
        locationService: InjectorApp.resolve<LocationService>(),
      )..add(const InitializeMap()),
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
            _centerOnUser(state.userLatitude!, state.userLongitude!);
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
              if (state is UserHomeLoaded && state.selectedBranch != null)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: _buildBranchCard(state.selectedBranch!),
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
    _radiusDebounceTimer?.cancel();
    _radiusDebounceTimer = Timer(
      const Duration(milliseconds: 300),
      () => context.read<UserHomeBloc>().add(ChangeRadius(_sliderRadius)),
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
                    color: branch.type == 'taller'
                        ? Colors.orange[50]
                        : Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    branch.type == 'taller' ? Icons.build : Icons.store,
                    color: branch.type == 'taller'
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
                if (branch.distanceKm != null)
                  Text(
                    '${branch.distanceKm!.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => _navigateToBranchDetail(context, branch),
                  child: const Text(CommonConstants.seeMore),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openGoogleMaps(branch.latitude, branch.longitude),
                  icon: const Icon(Icons.directions),
                  label: const Text(CommonConstants.howToGetThere),
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
                    create: (context) => ChangePasswordBloc(),
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
