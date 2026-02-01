import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/verification_page.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/widgets/register_form.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/widgets/representative_info_box.dart';

class RegisterRepresentativePage extends StatelessWidget {
  final VoidCallback? onSwitchToLogin;
  const RegisterRepresentativePage({super.key, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          getTranslateText(context: context, key: 'register_representative'),
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<RegisterPersonBloc, RegisterPersonState>(
        listener: (context, state) {
          if (state is RegisterPersonSuccess) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  getTranslateText(
                    context: context,
                    key: 'verification_email_sent',
                  ),
                ),
                backgroundColor: Colors.green[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 16,
                ),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationPage(email: state.email),
              ),
            );
          } else if (state is RegisterPersonFailure) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorModel.message),
                backgroundColor: Colors.red[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 16,
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 800
                    ? 600
                    : (MediaQuery.of(context).size.width > 600
                          ? 500
                          : double.infinity),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 5 : 32,
                  vertical: isMobile ? 12 : 24,
                ),
                child: Column(
                  children: [
                    RegisterForm(
                      role: 'representative',
                      title: getTranslateText(
                        context: context,
                        key: 'create_representative_account',
                      ),
                      subtitle: getTranslateText(
                        context: context,
                        key: 'complete_data_representative',
                      ),
                      buttonText: getTranslateText(
                        context: context,
                        key: 'create_representative_account',
                      ),
                      primaryColor: Colors.orange,
                      icon: Icons.store,
                      extraContent: const RepresentativeInfoBox(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
