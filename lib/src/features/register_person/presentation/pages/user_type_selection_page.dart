import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';

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
                        maxWidth: _maxContentWidth(isTablet, isLargeTablet),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 20.0 : 32.0,
                          vertical: isMobile ? 20.0 : 32.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogo(context, isMobile, isTablet),
                            SizedBox(height: isMobile ? 24 : 32),
                            _buildAppName(context, isMobile, isTablet),
                            SizedBox(height: isMobile ? 16 : 24),
                            _buildMainTitle(context, isMobile, isTablet),
                            SizedBox(height: isMobile ? 12 : 16),
                            _buildSubtitle(context, isMobile),
                            SizedBox(height: isMobile ? 40 : 56),
                            _buildUserTypeCards(
                              context,
                              isMobile,
                              isLargeTablet,
                            ),
                            SizedBox(height: isMobile ? 40 : 56),
                            _buildLoginLink(context, isMobile),
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

  /// Calculates the max content width based on screen breakpoints.
  double _maxContentWidth(bool isTablet, bool isLargeTablet) {
    if (isLargeTablet) return 800;
    if (isTablet) return 600;
    return double.infinity;
  }

  /// Returns a responsive value for mobile / tablet / large screens.
  double _responsiveValue({
    required bool isMobile,
    required bool isTablet,
    required double mobile,
    required double tablet,
    required double large,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return large;
  }

  /// Logo icon container with responsive sizing.
  Widget _buildLogo(BuildContext context, bool isMobile, bool isTablet) {
    final dimension = _responsiveValue(
      isMobile: isMobile,
      isTablet: isTablet,
      mobile: 80,
      tablet: 100,
      large: 120,
    );
    final iconSize = _responsiveValue(
      isMobile: isMobile,
      isTablet: isTablet,
      mobile: 40,
      tablet: 50,
      large: 60,
    );

    return Container(
      height: dimension,
      width: dimension,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withAlpha(75),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.motorcycle, color: Colors.white, size: iconSize),
    );
  }

  /// App name heading with responsive font size.
  Widget _buildAppName(BuildContext context, bool isMobile, bool isTablet) {
    final fontSize = _responsiveValue(
      isMobile: isMobile,
      isTablet: isTablet,
      mobile: 32,
      tablet: 40,
      large: 48,
    );

    return Text(
      getTranslateText(context: context, key: 'app_name'),
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
        fontSize: fontSize,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Main title with responsive font size.
  Widget _buildMainTitle(BuildContext context, bool isMobile, bool isTablet) {
    final fontSize = _responsiveValue(
      isMobile: isMobile,
      isTablet: isTablet,
      mobile: 24,
      tablet: 28,
      large: 32,
    );

    return Text(
      getTranslateText(context: context, key: 'user_type_selection_title'),
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.black87,
        fontSize: fontSize,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Subtitle text.
  Widget _buildSubtitle(BuildContext context, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0),
      child: Text(
        getTranslateText(context: context, key: 'user_type_selection_subtitle'),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.grey[600],
          fontSize: isMobile ? 16 : 18,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Lays out user type cards side-by-side on large tablets, stacked otherwise.
  Widget _buildUserTypeCards(
    BuildContext context,
    bool isMobile,
    bool isLargeTablet,
  ) {
    final motorcyclistCard = _buildUserTypeCard(
      context: context,
      title: getTranslateText(context: context, key: 'motorcyclist_title'),
      subtitle: getTranslateText(
        context: context,
        key: 'motorcyclist_subtitle',
      ),
      icon: Icons.motorcycle,
      iconColor: Colors.blue[600]!,
      onTap: () => Navigator.pushNamed(context, '/register/user'),
      isCompact: isMobile,
    );
    final representativeCard = _buildUserTypeCard(
      context: context,
      title: getTranslateText(context: context, key: 'representative_title'),
      subtitle: getTranslateText(
        context: context,
        key: 'representative_subtitle',
      ),
      icon: Icons.store,
      iconColor: Colors.orange[600]!,
      onTap: () => Navigator.pushNamed(context, '/register/representative'),
      isCompact: isMobile,
    );

    if (isLargeTablet) {
      return Row(
        children: [
          Expanded(child: motorcyclistCard),
          const SizedBox(width: 24),
          Expanded(child: representativeCard),
        ],
      );
    }

    return Column(
      children: [
        motorcyclistCard,
        SizedBox(height: isMobile ? 16 : 20),
        representativeCard,
      ],
    );
  }

  /// "Already have an account? Sign in" link.
  Widget _buildLoginLink(BuildContext context, bool isMobile) {
    return Wrap(
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
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
