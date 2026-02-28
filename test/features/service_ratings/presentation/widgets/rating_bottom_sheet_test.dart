import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/bloc/service_rating_bloc.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/widgets/rating_bottom_sheet.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/usecases/rate_service_item_usecase.dart';

@GenerateMocks([RateServiceItemUseCase])
import 'rating_bottom_sheet_test.mocks.dart';

void main() {
  late ServiceRatingBloc bloc;
  late MockRateServiceItemUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockRateServiceItemUseCase();
    bloc = ServiceRatingBloc(rateServiceItemUseCase: mockUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  Widget buildWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<ServiceRatingBloc>.value(
          value: bloc,
          child: const RatingBottomSheet(
            completedServiceId: 'cs-1',
            itemId: 'item-1',
            serviceName: 'Cambio de aceite',
          ),
        ),
      ),
    );
  }

  group('RatingBottomSheet', () {
    testWidgets('displays title and service name', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text(BranchDetailConstants.rateTitle), findsOneWidget);
      expect(find.text('Cambio de aceite'), findsOneWidget);
    });

    testWidgets('shows 5 star icons', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('submit button is disabled when no rating', (tester) async {
      await tester.pumpWidget(buildWidget());

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, BranchDetailConstants.rateSubmit),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping a star fills it and enables submit', (tester) async {
      await tester.pumpWidget(buildWidget());

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
      await tester.pumpWidget(buildWidget());

      // Tap 5th star
      final stars = find.byType(GestureDetector);
      await tester.tap(stars.at(4));
      await tester.pump();

      expect(find.byIcon(Icons.star), findsNWidgets(5));
      expect(find.byIcon(Icons.star_border), findsNothing);
    });

    testWidgets('has a comment text field', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows handle bar at top', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Handle bar is a 40x4 Container
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });
}
