import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/email_verification_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/widgets/email_verification_widget.dart';

class EmailRecoveryVerificationPage extends StatelessWidget {
  final String? email;

  const EmailRecoveryVerificationPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Recuperar contraseña',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<EmailRecoveryVerificationBloc, EmailRecoveryVerificationState>(
        listener: (context, state) {},
        child: SafeArea(
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

                       
                              Container(
                                height: isMobile ? 80 : 100,
                                width: isMobile ? 80 : 100,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.lock_reset_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: isMobile ? 40 : 50,
                                ),
                              ),

                              SizedBox(height: isMobile ? 24 : 32),

                      
                              Text(
                                'Recuperar contraseña',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 22 : 28,
                                      color: Colors.black87,
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 12 : 16),

                      
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 16,
                                ),
                                child: Text(
                                  'Ingresa tu correo electrónico y te enviaremos un código de verificación para restablecer tu contraseña.',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontSize: isMobile ? 16 : 18,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

                    
                              const EmailVerificationWidget(),

                              SizedBox(height: isMobile ? 24 : 32),

                      
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Volver al inicio de sesión',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),

                              const Spacer(),

                      
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 16,
                                ),
                                child: Text(
                                  '¿Tienes problemas? Contacta con nuestro equipo de soporte.',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: isMobile ? 12 : 13,
                                        color: Colors.grey[500],
                                        height: 1.4,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: isMobile ? 16 : 20),
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
      ),
    );
  }
}
