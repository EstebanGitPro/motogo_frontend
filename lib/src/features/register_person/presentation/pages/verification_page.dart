import 'dart:async';
import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';

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
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 600 : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16.0 : 24.0,
                          vertical: isMobile ? 16.0 : 24.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),

                            // Success Icon
                            Container(
                              height: isMobile ? 100 : 120,
                              width: isMobile ? 100 : 120,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Icon(
                                Icons.check_circle_outline,
                                color: Colors.green[600],
                                size: isMobile ? 60 : 70,
                              ),
                            ),

                            SizedBox(height: isMobile ? 32 : 40),

                            // Success Title
                            Text(
                              '¡Registro exitoso!',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 24 : 28,
                                    color: Colors.black87,
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: isMobile ? 16 : 20),

                            // Email Icon + Message
                            Icon(
                              Icons.email_outlined,
                              color: Theme.of(context).primaryColor,
                              size: isMobile ? 48 : 56,
                            ),

                            SizedBox(height: isMobile ? 16 : 20),

                            // Instruction Text
                            Text(
                              'Revisa tu correo electrónico',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: isMobile ? 18 : 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: isMobile ? 12 : 16),

                            // Subtitle
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 24,
                              ),
                              child: Text(
                                'Enviamos un enlace de verificación a:',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontSize: isMobile ? 15 : 16,
                                      color: Colors.grey[600],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: isMobile ? 12 : 16),

                            // Email Display
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                horizontal: isMobile ? 0 : 16,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 20,
                                vertical: isMobile ? 14 : 16,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                widget.email,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isMobile ? 15 : 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 32),

                            // Info Container
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                horizontal: isMobile ? 0 : 16,
                              ),
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
                                      'El correo puede tardar unos minutos en llegar. Revisa tu carpeta de spam si no lo ves.',
                                      style: TextStyle(
                                        fontSize: isMobile ? 13 : 14,
                                        color: Colors.blue[900],
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isMobile ? 32 : 40),

                            // Redirect Countdown
                            Container(
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
                                    _secondsRemaining > 0
                                        ? 'Redirigiendo al login en $_secondsRemaining segundos...'
                                        : 'Redirigiendo...',
                                    style: TextStyle(
                                      fontSize: isMobile ? 13 : 14,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 32),

                            // Manual redirect button
                            TextButton(
                              onPressed: () {
                                _redirectTimer?.cancel();
                                _countdownTimer?.cancel();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
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
                            ),

                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
