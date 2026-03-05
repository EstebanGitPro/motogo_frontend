import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:motogo_frontend/src/core/constants/debug_messages.dart';
import 'package:motogo_frontend/src/core/constants/splash_constants.dart';
import 'package:motogo_frontend/src/core/config/config.dart';
import 'package:motogo_frontend/src/core/user/data/models/user_model.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/core/utils/app_logger.dart';

/// Splash screen for MotoGo with animated logo and text.
///
/// After the animation completes, validates the session and navigates to:
/// - `/home` or `/admin-home` if a **valid** session exists (backend confirms)
/// - `/user-type-selection` if no session exists or validation fails
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _textFade;
  late final Animation<double> _textSlide;

  @override
  void initState() {
    super.initState();

    // Logo animation: fade-in + slide-up over 1.2s
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
        );

    // Text animation: fade-in + slight slide-up over 800ms
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut);

    _textSlide = Tween<double>(
      begin: 20.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _startAnimationSequence();
  }

  bool _showLoading = true;

  Future<void> _startAnimationSequence() async {
    // Remove the native splash screen now that our Flutter UI is ready
    FlutterNativeSplash.remove();

    // Show loading indicator briefly while everything initializes
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _showLoading = false);

    // Start logo animation
    unawaited(_logoController.forward());

    // Wait for logo to mostly finish, then start text
    await Future.delayed(const Duration(milliseconds: 800));
    unawaited(_textController.forward());

    // Wait for everything to finish + pause for branding impression
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    final session = UserSessionManager.instance;
    String route = SplashConstants.routeUserTypeSelection;

    if (session.isAuthenticated) {
      // Validate session with backend and refresh cached user data
      final freshUser = await _validateAndRefreshSession(session.accessToken!);

      if (freshUser != null) {
        // Session confirmed — use the FRESH role from backend, not cache
        final role = freshUser.role;
        if (role == SplashConstants.roleAdmin ||
            role == SplashConstants.roleRepresentative) {
          route = SplashConstants.routeAdminHome;
        } else {
          route = SplashConstants.routeUserHome;
        }
      } else {
        // Backend unreachable or token invalid → clear stale session
        await session.clearSession();
        AppLogger.auth(DebugMessages.staleSessionCleared);
      }
    }

    if (!mounted) return;
    unawaited(Navigator.of(context).pushReplacementNamed(route));
  }

  /// Validates the stored token by calling `/persons/me` and refreshes
  /// the cached user data with the backend response.
  ///
  /// Returns the fresh [UserModel] if the backend confirms the token is valid,
  /// or `null` if the backend is unreachable or the token is invalid/expired.
  Future<UserModel?> _validateAndRefreshSession(String token) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: Config.baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final response = await dio.get(
        SplashConstants.meEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData?['success'] != true) return null;

      final userData = responseData!['data'] as Map<String, dynamic>?;
      if (userData == null) return null;

      // Parse fresh user data from backend and update cache
      final freshUser = UserModel.fromMap(userData);
      await UserSessionManager.instance.updateUser(freshUser);
      AppLogger.auth(
        '${DebugMessages.sessionRefreshedPrefix}${freshUser.role}',
      );

      return freshUser;
    } catch (e) {
      AppLogger.error(DebugMessages.sessionValidationFailed, e);
      return null;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _showLoading ? _buildLoadingView() : _buildSplashView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(
          color: Color(0xFF1565C0),
          strokeWidth: 3,
        ),
        const SizedBox(height: 24),
        Text(
          SplashConstants.loadingText,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSplashView() {
    return Column(
      key: const ValueKey('splash'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated motorcycle logo
        SlideTransition(
          position: _logoSlide,
          child: FadeTransition(
            opacity: _logoFade,
            child: Image.asset(
              SplashConstants.logoAsset,
              width: 180,
              height: 180,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Animated "MOTOGO" text
        AnimatedBuilder(
          animation: _textController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _textSlide.value),
              child: Opacity(opacity: _textFade.value, child: child),
            );
          },
          child: const Text(
            SplashConstants.appName,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: 10,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}
