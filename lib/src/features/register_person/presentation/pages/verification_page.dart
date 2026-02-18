import 'dart:async';

import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/core/widgets/responsive_scaffold_body.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _secondsRemaining = 7;
  Timer? _redirectTimer;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startRedirectCountdown();
  }

  void _startRedirectCountdown() {
    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });

    // Redirect after 3 seconds
    _redirectTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, isMobile),
      body: ResponsiveScaffoldBody(
        maxWidth: isTablet ? 600 : double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : 24.0,
          vertical: isMobile ? 16.0 : 24.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            _buildSuccessIcon(isMobile),
            SizedBox(height: isMobile ? 32 : 40),
            _buildSuccessTitle(context, isMobile),
            SizedBox(height: isMobile ? 16 : 20),
            _buildEmailInstruction(context, isMobile),
            SizedBox(height: isMobile ? 24 : 32),
            _buildInfoBanner(isMobile),
            SizedBox(height: isMobile ? 32 : 40),
            _buildCountdownIndicator(context, isMobile),
            SizedBox(height: isMobile ? 24 : 32),
            _buildRedirectButton(context, isMobile),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// Builds the AppBar with translated title.
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isMobile) {
    return AppBar(
      title: Text(
        getTranslateText(context: context, key: 'account_verification'),
        style: TextStyle(
          fontSize: isMobile ? 18 : 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
    );
  }

  /// Green check-circle icon container.
  Widget _buildSuccessIcon(bool isMobile) {
    final dimension = isMobile ? 100.0 : 120.0;
    return Container(
      height: dimension,
      width: dimension,
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(60),
      ),
      child: Icon(
        Icons.check_circle_outline,
        color: Colors.green[600],
        size: isMobile ? 60 : 70,
      ),
    );
  }

  /// Title "¡Registro exitoso!" heading.
  Widget _buildSuccessTitle(BuildContext context, bool isMobile) {
    return Text(
      '¡Registro exitoso!',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: isMobile ? 24 : 28,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Email icon, instruction text, subtitle, and email display container.
  Widget _buildEmailInstruction(BuildContext context, bool isMobile) {
    final primaryColor = Theme.of(context).primaryColor;
    final horizontalMargin = isMobile ? 0.0 : 16.0;

    return Column(
      children: [
        Icon(
          Icons.email_outlined,
          color: primaryColor,
          size: isMobile ? 48 : 56,
        ),
        SizedBox(height: isMobile ? 16 : 20),
        Text(
          'Revisa tu correo electrónico',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          child: Text(
            'Enviamos un enlace de verificación a:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: isMobile ? 15 : 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 20,
            vertical: isMobile ? 14 : 16,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Text(
            widget.email,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 15 : 16,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Blue info banner about checking spam folder.
  Widget _buildInfoBanner(bool isMobile) {
    final horizontalMargin = isMobile ? 0.0 : 16.0;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue[700],
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Text(
              'El correo puede tardar unos minutos en llegar. '
              'Revisa tu carpeta de spam si no lo ves.',
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                color: Colors.blue[900],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Countdown pill with spinner and redirect text.
  Widget _buildCountdownIndicator(BuildContext context, bool isMobile) {
    final countdownText = _secondsRemaining > 0
        ? 'Redirigiendo al login en $_secondsRemaining segundos...'
        : 'Redirigiendo...';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 24,
        vertical: isMobile ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Text(
            countdownText,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Manual "go to login now" button.
  Widget _buildRedirectButton(BuildContext context, bool isMobile) {
    return TextButton(
      onPressed: () {
        _redirectTimer?.cancel();
        _countdownTimer?.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      },
      child: Text(
        'Ir al login ahora',
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
