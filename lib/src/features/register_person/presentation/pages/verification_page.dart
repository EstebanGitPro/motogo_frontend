import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';

class VerificationPage extends StatefulWidget {
  final String email;

  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<RegisterPersonBloc>().add(StartVerification(widget.email));
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
      ),
      body: BlocListener<RegisterPersonBloc, RegisterPersonState>(
        listener: (context, state) {
          if (state is VerificationPersonSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(getTranslateText(context: context, key: 'email_verified_success'))),
            );
          } else if (state is VerificationPersonFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorModel.message)));
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
                                  ).primaryColor.withAlpha(1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Icon(
                                  Icons.mark_email_unread_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: isMobile ? 40 : 50,
                                ),
                              ),

                              SizedBox(height: isMobile ? 24 : 32),

                              Text(
                                getTranslateText(context: context, key: 'verify_email'),
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
                                getTranslateText(context: context, key: 'verification_email_sent'),
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

                              SizedBox(height: isMobile ? 20 : 24),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 8 : 16,
                                ),
                                child: Text(
                                  getTranslateText(context: context, key: 'check_inbox'),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: isMobile ? 14 : 16,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

                              SizedBox(
                                height: isMobile ? 24 : 32,
                                width: isMobile ? 24 : 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),

                              SizedBox(height: isMobile ? 12 : 16),

                              Text(
                                getTranslateText(context: context, key: 'waiting_verification'),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: isMobile ? 14 : 16,
                                      color: Colors.grey[600],
                                    ),
                              ),

                              SizedBox(height: isMobile ? 32 : 40),

                              SizedBox(height: isMobile ? 16 : 20),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  getTranslateText(context: context, key: 'back_to_register'),
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
                                  getTranslateText(context: context, key: 'no_email_received'),
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
