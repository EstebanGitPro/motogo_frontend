import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/widgets/button_widget.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/code_validation_bloc.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/widgets/code_input.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/pages/password_reset_page.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email;

  const CodeVerificationPage({super.key, required this.email});

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  String _enteredCode = '';
  bool _isCodeComplete = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Verificación de código',
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
      body: BlocListener<CodeValidationBloc, CodeValidationState>(
        listener: (context, state) {
         
          ScaffoldMessenger.of(context).clearSnackBars();
          
          if (state is CodeValidationSuccess) {
           
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => PasswordResetPage(
                  email: widget.email,
                  verificationCode: _enteredCode,
                ),
              ),
            );
          } else if (state is CodeValidationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error.message),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.red,
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
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withAlpha(20),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.security_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: isMobile ? 40 : 50,
                                ),
                              ),

                              SizedBox(height: isMobile ? 24 : 32),

                   
                              Text(
                                'Ingresa el código de verificación',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 22 : 28,
                                      color: Colors.black87,
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 12 : 16),

                       
                              Text(
                                'Se ha enviado un código de 6 dígitos a:',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      fontSize: isMobile ? 16 : 18,
                                      color: Colors.grey[700],
                                    ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isMobile ? 8 : 12),

                            
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
                                child: Text(
                                  widget.email,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isMobile ? 16 : 18,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

                              CodeInputWidget(
                                length: 6,
                                onChanged: (value) {
                                  setState(() {
                                    _enteredCode = value;
                                    _isCodeComplete = value.length == 6;
                                  });
                                },
                                onCompleted: (value) {
                                  setState(() {
                                    _enteredCode = value;
                                    _isCodeComplete = true;
                                  });
                                },
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

              
                              BlocBuilder<CodeValidationBloc, CodeValidationState>(
                                builder: (context, state) {
                                  final isLoading = state is CodeValidationLoading;

                                  return CustomButtonWidget(
                                    title: 'Verificar código',
                                    isLoading: isLoading,
                                    onPressed: _isCodeComplete
                                        ? () {
                                            context.read<CodeValidationBloc>().add(
                                                  CodeValidationSubmitted(
                                                    code: _enteredCode,
                                                  ),
                                                );
                                          }
                                        : null,
                                  );
                                },
                              ),

                              SizedBox(height: isMobile ? 24 : 32),

                              const Spacer(),

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
