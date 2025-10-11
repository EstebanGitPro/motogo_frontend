import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';

class UserTypeSelectionPage extends StatelessWidget {
  final VoidCallback? onSwitchToLogin;
  const UserTypeSelectionPage({super.key, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width < 600;
    final isLargeTablet = screenSize.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
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
                        maxWidth: isTablet
                            ? (isLargeTablet ? 800 : 600)
                            : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20.0 : 32.0,
                          vertical: isMobile ? 20.0 : 32.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo container
                            Container(
                              height: isMobile ? 80 : (isTablet ? 100 : 120),
                              width: isMobile ? 80 : (isTablet ? 100 : 120),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withAlpha(75),
                                    spreadRadius: 2,
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.motorcycle,
                                color: Colors.white,
                                size: isMobile ? 40 : (isTablet ? 50 : 60),
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 32),

                            // App name
                            Text(
                              getTranslateText(context: context, key: 'app_name'),
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: isMobile
                                        ? 32
                                        : (isTablet ? 40 : 48),
                                    letterSpacing: -0.5,
                                  ),
                            ),

                            SizedBox(height: isMobile ? 16 : 24),

                            // Main title
                            Text(
                              getTranslateText(context: context, key: 'user_type_selection_title'),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    fontSize: isMobile
                                        ? 24
                                        : (isTablet ? 28 : 32),
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: isMobile ? 12 : 16),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16.0 : 24.0,
                              ),
                              child: Text(
                                getTranslateText(context: context, key: 'user_type_selection_subtitle'),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: isMobile ? 16 : 18,
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: isMobile ? 40 : 56),

                            if (isLargeTablet)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildUserTypeCard(
                                      context: context,
                                      title: getTranslateText(context: context, key: 'motorcyclist_title'),
                                      subtitle: getTranslateText(context: context, key: 'motorcyclist_subtitle'),
                                      icon: Icons.motorcycle,
                                      iconColor: Colors.blue[600]!,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/register/user',
                                      ),
                                      isCompact: false,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildUserTypeCard(
                                      context: context,
                                      title: getTranslateText(context: context, key: 'representative_title'),
                                      subtitle: getTranslateText(context: context, key: 'representative_subtitle'),
                                      icon: Icons.store,
                                      iconColor: Colors.orange[600]!,
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/register/representative',
                                      ),
                                      isCompact: false,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildUserTypeCard(
                                    context: context,
                                    title: getTranslateText(context: context, key: 'motorcyclist_title'),
                                    subtitle: getTranslateText(context: context, key: 'motorcyclist_subtitle'),
                                    icon: Icons.motorcycle,
                                    iconColor: Colors.blue[600]!,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/register/user',
                                    ),
                                    isCompact: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 16 : 20),
                                  _buildUserTypeCard(
                                    context: context,
                                    title: getTranslateText(context: context, key: 'representative_title'),
                                    subtitle: getTranslateText(context: context, key: 'representative_subtitle'),
                                    icon: Icons.store,
                                    iconColor: Colors.orange[600]!,
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/register/representative',
                                    ),
                                    isCompact: isMobile,
                                  ),
                                ],
                              ),

                            SizedBox(height: isMobile ? 40 : 56),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  getTranslateText(context: context, key: 'already_have_account'),
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: Text(
                                    getTranslateText(context: context, key: 'sign_in'),
                                    style: TextStyle(
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: isMobile ? 20 : 24),
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

  Widget _buildUserTypeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required bool isCompact,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 24 : 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon container
                Container(
                  width: isCompact ? 60 : 80,
                  height: isCompact ? 60 : 80,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: isCompact ? 30 : 40,
                    color: iconColor,
                  ),
                ),
                SizedBox(height: isCompact ? 16 : 24),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 18 : 22,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isCompact ? 8 : 12),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontSize: isCompact ? 14 : 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isCompact ? 16 : 20),
                // Arrow indicator
                Icon(
                  Icons.arrow_forward,
                  color: iconColor,
                  size: isCompact ? 20 : 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
