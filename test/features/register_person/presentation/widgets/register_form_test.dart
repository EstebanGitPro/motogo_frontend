import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/widgets/register_form.dart';

@GenerateMocks([RegisterPersonBloc, LoginBloc])
import 'register_form_test.mocks.dart';

void main() {
  late MockRegisterPersonBloc mockRegisterBloc;
  late MockLoginBloc mockLoginBloc;

  setUp(() {
    mockRegisterBloc = MockRegisterPersonBloc();
    mockLoginBloc = MockLoginBloc();
    when(mockRegisterBloc.state).thenReturn(RegisterPersonInitial());
    when(mockRegisterBloc.stream).thenAnswer((_) => const Stream.empty());
    when(mockLoginBloc.state).thenReturn(LoginInitial());
    when(mockLoginBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget buildSubject(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;

    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RegisterPersonBloc>.value(value: mockRegisterBloc),
            BlocProvider<LoginBloc>.value(value: mockLoginBloc),
          ],
          child: const RegisterForm(
            role: 'user',
            title: 'Crear cuenta',
            subtitle: 'Completa tus datos',
            buttonText: 'Crear cuenta',
            primaryColor: Colors.blue,
            icon: Icons.motorcycle,
          ),
        ),
      ),
    );
  }

  group('RegisterForm Legal Checkboxes', () {
    testWidgets('terms checkbox is unchecked by default', (tester) async {
      await tester.pumpWidget(buildSubject(tester));

      final checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('terms_checkbox')),
      );
      expect(checkbox.value, isFalse);
    });

    testWidgets('sensitive data checkbox is unchecked by default', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(tester));

      final checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('sensitive_data_checkbox')),
      );
      expect(checkbox.value, isFalse);
    });

    testWidgets('commercial comms checkbox is unchecked by default', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(tester));

      final checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('commercial_comms_checkbox')),
      );
      expect(checkbox.value, isFalse);
    });

    testWidgets('register button is disabled when no checkboxes accepted', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(tester));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('register button is disabled when only terms accepted', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(tester));

      // Accept only terms
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'register button is disabled when only sensitive data accepted',
      (tester) async {
        await tester.pumpWidget(buildSubject(tester));

        // Accept only sensitive data
        await tester.tap(find.byKey(const Key('sensitive_data_checkbox')));
        await tester.pumpAndSettle();

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets(
      'register button is enabled when both mandatory checkboxes accepted',
      (tester) async {
        await tester.pumpWidget(buildSubject(tester));

        // Accept terms
        await tester.tap(find.byKey(const Key('terms_checkbox')));
        await tester.pumpAndSettle();

        // Accept sensitive data
        await tester.tap(find.byKey(const Key('sensitive_data_checkbox')));
        await tester.pumpAndSettle();

        // Button should now be enabled
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNotNull);
      },
    );

    testWidgets('toggling terms checkbox updates state', (tester) async {
      await tester.pumpWidget(buildSubject(tester));

      // Initially unchecked
      var checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('terms_checkbox')),
      );
      expect(checkbox.value, isFalse);

      // Check it
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('terms_checkbox')),
      );
      expect(checkbox.value, isTrue);

      // Uncheck it
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();

      checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('terms_checkbox')),
      );
      expect(checkbox.value, isFalse);
    });

    testWidgets('toggling sensitive data checkbox updates state', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(tester));

      var checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('sensitive_data_checkbox')),
      );
      expect(checkbox.value, isFalse);

      await tester.tap(find.byKey(const Key('sensitive_data_checkbox')));
      await tester.pumpAndSettle();

      checkbox = tester.widget<Checkbox>(
        find.byKey(const Key('sensitive_data_checkbox')),
      );
      expect(checkbox.value, isTrue);
    });

    testWidgets('commercial comms checkbox is independent and optional', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(tester));

      // Accept both mandatory checkboxes
      await tester.tap(find.byKey(const Key('terms_checkbox')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sensitive_data_checkbox')));
      await tester.pumpAndSettle();

      // Button enabled without commercial comms
      var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);

      // Toggle commercial comms — button should still be enabled
      await tester.tap(find.byKey(const Key('commercial_comms_checkbox')));
      await tester.pumpAndSettle();

      final commsCheckbox = tester.widget<Checkbox>(
        find.byKey(const Key('commercial_comms_checkbox')),
      );
      expect(commsCheckbox.value, isTrue);

      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('all three checkboxes are rendered', (tester) async {
      await tester.pumpWidget(buildSubject(tester));

      expect(find.byKey(const Key('terms_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('sensitive_data_checkbox')), findsOneWidget);
      expect(
        find.byKey(const Key('commercial_comms_checkbox')),
        findsOneWidget,
      );
    });
  });
}
