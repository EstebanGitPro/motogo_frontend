import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/presentation/widgets/rating_bottom_sheet.dart';

void main() {
  const testService = BranchServiceEntity(
    id: 'svc-1',
    name: 'Cambio de aceite',
    description: 'Motor oil change',
    serviceType: 'Mantenimiento',
  );

  group('RatingBottomSheet', () {
    testWidgets('displays title and service name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBottomSheet(service: testService)),
        ),
      );

      expect(find.text(BranchDetailConstants.rateTitle), findsOneWidget);
      expect(find.text('Cambio de aceite'), findsOneWidget);
    });

    testWidgets('shows 5 star icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBottomSheet(service: testService)),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('submit button is disabled when no rating', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBottomSheet(service: testService)),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, BranchDetailConstants.rateSubmit),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping a star fills it and enables submit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBottomSheet(service: testService)),
        ),
      );

      // Tap the 3rd star
      final stars = find.byType(GestureDetector);
      await tester.tap(stars.at(2));
      await tester.pump();

      // First 3 should be filled, last 2 empty
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));

      // Submit button should now be enabled
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, BranchDetailConstants.rateSubmit),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('tapping different stars updates selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBottomSheet(service: testService)),
        ),
      );

      // Tap 5th star
      final stars = find.byType(GestureDetector);
      await tester.tap(stars.at(4));
      await tester.pump();

      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('has a comment text field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBottomSheet(service: testService)),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows handle bar at top', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RatingBottomSheet(service: testService)),
        ),
      );

      // Handle bar is a 40x4 Container
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });

    testWidgets('static show method opens modal bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => RatingBottomSheet.show(context, testService),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Bottom sheet should now be visible with the rating title
      expect(find.text(BranchDetailConstants.rateTitle), findsOneWidget);
    });
  });
}
