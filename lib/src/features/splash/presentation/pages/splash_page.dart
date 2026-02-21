import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';

/// Splash screen for MotoGo with animated logo and text.
///
/// After the animation completes, navigates to:
/// - `/home` or `/admin-home` if a session is already active
/// - `/` (UserTypeSelectionPage) if no session exists
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

  Future<void> _startAnimationSequence() async {
    // Small initial delay for visual polish
    await Future.delayed(const Duration(milliseconds: 300));

    // Start logo animation
    unawaited(_logoController.forward());

    // Wait for logo to mostly finish, then start text
    await Future.delayed(const Duration(milliseconds: 800));
    unawaited(_textController.forward());

    // Wait for everything to finish + pause for branding impression
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    final session = UserSessionManager.instance;
    final String route;

    if (session.isAuthenticated) {
      // Navigate based on user role
      final role = session.currentUser?.role ?? '';
      if (role == 'ADMIN' || role == 'REPRESENTATIVE') {
        route = '/admin-home';
      } else {
        route = '/home';
      }
    } else {
      route = '/user-type-selection';
    }

    Navigator.of(context).pushReplacementNamed(route);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated motorcycle logo
            SlideTransition(
              position: _logoSlide,
              child: FadeTransition(
                opacity: _logoFade,
                child: Image.asset(
                  'assets/icons/motogo_logo.png',
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
                'MOTOGO',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
