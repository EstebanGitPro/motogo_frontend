import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/password_recovery_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/widgets/password_reset_widget.dart';

class PasswordResetPage extends StatefulWidget {
  final String email;
  final String verificationCode;

  const PasswordResetPage({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  void _onPasswordSubmit(String password, String confirmPassword) {
    context.read<PasswordRecoveryBloc>().add(
      ResetPasswordSubmitted(
        code: widget.verificationCode,
        newPassword: password,
      ),
    );
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
          'Nueva contraseña',
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
      body: BlocListener<PasswordRecoveryBloc, PasswordResetState>(
        listener: (context, state) {
        
          ScaffoldMessenger.of(context).clearSnackBars();
          
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Contraseña actualizada correctamente!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
         
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is PasswordResetFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
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
                                  color: Theme.of(context).primaryColor.withAlpha(20),
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
                                'Crear nueva contraseña',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 22 : 28,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 12 : 16),

                          
                              Text(
                                'Tu nueva contraseña debe ser diferente a las anteriores',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: isMobile ? 16 : 18,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

                        
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 0 : 16,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 20,
                                  vertical: isMobile ? 12 : 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      color: Theme.of(context).primaryColor,
                                      size: isMobile ? 16 : 18,
                                    ),
                                    SizedBox(width: isMobile ? 8 : 10),
                                    Text(
                                      widget.email,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isMobile ? 14 : 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

                    
                              BlocBuilder<PasswordRecoveryBloc, PasswordResetState>(
                                builder: (context, state) {
                                  final isLoading = state is PasswordResetLoading;
                                  
                                  return PasswordResetWidget(
                                    onPasswordSubmit: _onPasswordSubmit,
                                    isLoading: isLoading,
                                  );
                                },
                              ),

                              const Spacer(),

                
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 16,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                                  decoration: BoxDecoration(
                                    color: Colors.amber[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.security_outlined,
                                        color: Colors.amber[700],
                                        size: isMobile ? 16 : 18,
                                      ),
                                      SizedBox(width: isMobile ? 8 : 10),
                                      Expanded(
                                        child: Text(
                                          'Por tu seguridad, asegúrate de usar una contraseña única y fuerte.',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontSize: isMobile ? 12 : 13,
                                            color: Colors.amber[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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