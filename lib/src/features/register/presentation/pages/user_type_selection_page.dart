import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/features/login/presentation/pages/login_page.dart';
import 'package:motogo_frontend/src/features/register/presentation/widgets/custom_button.dart';

class UserTypeSelectionPage extends StatelessWidget {
  final VoidCallback? onSwitchToLogin;
  const UserTypeSelectionPage({super.key, this.onSwitchToLogin});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isMobile = screenSize.width < 600;

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
                        maxWidth: isTablet ? 600 : double.infinity,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16.0 : 24.0,
                          vertical: isMobile ? 16.0 : 24.0,
                        ),
                        child: Column(
                          children: [
                            
                            SizedBox(height: isMobile ? 16 : 20),

                          
                            Container(
                              height: isMobile ? 60 : 70,
                              width: isMobile ? 70 : 80,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.motorcycle,
                                color: Colors.white,
                                size: isMobile ? 30 : 40,
                              ),
                            ),

                            SizedBox(height: isMobile ? 16 : 20),

                           
                            Text(
                              'MotoGo',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                    fontSize: isMobile ? 28 : null,
                                  ),
                            ),

                            SizedBox(height: isMobile ? 8 : 12),

                            Text(
                              '¿Cómo quieres usar MotoGo?',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: isMobile ? 20 : null,
                                  ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: isMobile ? 6 : 8),

                
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 8.0 : 16.0,
                              ),
                              child: Text(
                                'Selecciona el tipo de cuenta que mejor se adapte a tus necesidades',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: isMobile ? 14 : null,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: isMobile ? 24 : 40),

      
                            if (isTablet && screenSize.width > 800)
                            
                              Row(
                                children: [
                                  Expanded(
                                    child: UserTypeButton(
                                      title: 'Soy Motociclista',
                                      subtitle: 'Busco servicios para mi moto',
                                      icon: Icons.motorcycle,
                                      iconColor: Colors.blue,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register/user',
                                        );
                                      },
                                      isCompact: false,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: UserTypeButton(
                                      title: 'Represento una Sede',
                                      subtitle: 'Ofrezco servicios técnicos',
                                      icon: Icons.store,
                                      iconColor: Colors.green,
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/register/representative',
                                        );
                                      },
                                      isCompact: false,
                                    ),
                                  ),
                                ],
                              )
                            else
                              
                              Column(
                                children: [
                                  UserTypeButton(
                                    title: 'Soy Motociclista',
                                    subtitle: 'Busco servicios para mi moto',
                                    icon: Icons.motorcycle,
                                    iconColor: Colors.blue,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/register/user',
                                      );
                                    },
                                    isCompact: isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  UserTypeButton(
                                    title: 'Represento una Sede',
                                    subtitle: 'Ofrezco servicios técnicos',
                                    icon: Icons.store,
                                    iconColor: Colors.green,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/register/representative',
                                      );
                                    },
                                    isCompact: isMobile,
                                  ),
                                ],
                              ),

                          
                            SizedBox(height: isMobile ? 24 : 40),

                
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '¿Ya tienes una cuenta?',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : null,
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
                                  child: Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : null,
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}


