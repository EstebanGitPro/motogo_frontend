import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/helpers/register_person_listener.dart';
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
      body: buildRegisterPersonListener(
        context: context,
        isMobile: isMobile,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _maxContentWidth(MediaQuery.of(context).size.width),
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

  /// Calculates the max content width based on screen breakpoints.
  double _maxContentWidth(double screenWidth) {
    if (screenWidth > 800) return 600;
    if (screenWidth > 600) return 500;
    return double.infinity;
  }
}
