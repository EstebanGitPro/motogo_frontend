import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/features/splash/presentation/pages/splash_page.dart';

import 'splash_page_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserSessionManager sessionManager;
  late MockFlutterSecureStorage mockStorage;

  const motorcyclistUser = UserEntity(
    id: 'user-001',
    identityNumber: '123456789',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    role: 'MOTORCYCLIST',
  );

  const adminUser = UserEntity(
    id: 'admin-001',
    identityNumber: '987654321',
    firstName: 'Admin',
    lastName: 'García',
    email: 'admin@test.com',
    phoneNumber: '3009876543',
    role: 'ADMIN',
  );

  const representativeUser = UserEntity(
    id: 'rep-001',
    identityNumber: '111222333',
    firstName: 'Rep',
    lastName: 'López',
    email: 'rep@test.com',
    phoneNumber: '3005554444',
    role: 'REPRESENTATIVE',
  );

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    sessionManager = UserSessionManager.instance;
    sessionManager.resetForTesting();
    sessionManager.secureStorageOverride = mockStorage;

    // Default stubs
    when(
      mockStorage.write(key: anyNamed('key'), value: anyNamed('value')),
    ).thenAnswer((_) async {});
    when(mockStorage.delete(key: anyNamed('key'))).thenAnswer((_) async {});
    when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
  });

  tearDown(() {
    sessionManager.resetForTesting();
  });

  /// Builds the SplashPage inside a MaterialApp with named routes
  /// that record which route was navigated to.
  Widget buildTestApp({required ValueChanged<String> onNavigated}) {
    return MaterialApp(
      home: const SplashPage(),
      onGenerateRoute: (settings) {
        // Record the route that was navigated to
        onNavigated(settings.name ?? 'unknown');
        return MaterialPageRoute(
          builder: (_) =>
              Scaffold(body: Text('Navigated to: ${settings.name}')),
        );
      },
    );
  }

  group('SplashPage', () {
    group('UI rendering', () {
      testWidgets('should display the MOTOGO text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const SplashPage(),
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (_) => const Scaffold()),
          ),
        );

        // Pump enough frames for animation to reveal text
        await tester.pump(const Duration(milliseconds: 1200));

        expect(find.text('MOTOGO'), findsOneWidget);

        // Pump past remaining delays to avoid pending timer errors
        await tester.pump(const Duration(milliseconds: 2000));
        await tester.pumpAndSettle();
      });

      testWidgets('should have white background', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const SplashPage(),
            onGenerateRoute: (settings) =>
                MaterialPageRoute(builder: (_) => const Scaffold()),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.backgroundColor, Colors.white);

        // Pump past all delays to avoid pending timer errors
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();
      });
    });

    group('navigation - no session', () {
      testWidgets(
        'should navigate to /user-type-selection when not authenticated',
        (tester) async {
          String? navigatedRoute;

          await tester.pumpWidget(
            buildTestApp(onNavigated: (route) => navigatedRoute = route),
          );

          // Advance past all animation delays: 300 + 800 + 1500 = 2600ms
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 800));
          await tester.pump(const Duration(milliseconds: 1500));
          await tester.pumpAndSettle();

          expect(navigatedRoute, equals('/user-type-selection'));
        },
      );
    });

    group('navigation - authenticated MOTORCYCLIST', () {
      testWidgets(
        'should navigate to /home when authenticated with MOTORCYCLIST role',
        (tester) async {
          // Set up authenticated session
          await sessionManager.saveSession(
            accessToken: 'test-token',
            user: motorcyclistUser,
          );

          String? navigatedRoute;

          await tester.pumpWidget(
            buildTestApp(onNavigated: (route) => navigatedRoute = route),
          );

          // Advance past all animation delays
          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 800));
          await tester.pump(const Duration(milliseconds: 1500));
          await tester.pumpAndSettle();

          expect(navigatedRoute, equals('/home'));
        },
      );
    });

    group('navigation - authenticated ADMIN', () {
      testWidgets(
        'should navigate to /admin-home when authenticated with ADMIN role',
        (tester) async {
          await sessionManager.saveSession(
            accessToken: 'test-token',
            user: adminUser,
          );

          String? navigatedRoute;

          await tester.pumpWidget(
            buildTestApp(onNavigated: (route) => navigatedRoute = route),
          );

          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 800));
          await tester.pump(const Duration(milliseconds: 1500));
          await tester.pumpAndSettle();

          expect(navigatedRoute, equals('/admin-home'));
        },
      );
    });

    group('navigation - authenticated REPRESENTATIVE', () {
      testWidgets(
        'should navigate to /admin-home when authenticated with REPRESENTATIVE role',
        (tester) async {
          await sessionManager.saveSession(
            accessToken: 'test-token',
            user: representativeUser,
          );

          String? navigatedRoute;

          await tester.pumpWidget(
            buildTestApp(onNavigated: (route) => navigatedRoute = route),
          );

          await tester.pump(const Duration(milliseconds: 300));
          await tester.pump(const Duration(milliseconds: 800));
          await tester.pump(const Duration(milliseconds: 1500));
          await tester.pumpAndSettle();

          expect(navigatedRoute, equals('/admin-home'));
        },
      );
    });
  });
}
