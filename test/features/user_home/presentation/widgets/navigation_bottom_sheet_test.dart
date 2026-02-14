import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/navigation_bottom_sheet.dart';

void main() {
  const target = BranchMarkerEntity(
    id: 'b1',
    name: 'Taller MotoSpeed',
    type: 'taller',
    latitude: 4.60971,
    longitude: -74.08175,
  );

  Widget buildTestWidget({
    bool isLoadingRoute = false,
    bool isImmersiveMode = false,
    BranchMarkerEntity? navigationTarget = target,
    double? activeDistanceKm = 5.2,
    double? activeDurationMin = 12.0,
    double? liveDistanceKm,
    double? liveDurationMin,
    VoidCallback? onBeginImmersive,
    VoidCallback? onCancelRoute,
    VoidCallback? onOpenGoogleMaps,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: NavigationBottomSheet(
          isLoadingRoute: isLoadingRoute,
          isImmersiveMode: isImmersiveMode,
          navigationTarget: navigationTarget,
          activeDistanceKm: activeDistanceKm,
          activeDurationMin: activeDurationMin,
          liveDistanceKm: liveDistanceKm,
          liveDurationMin: liveDurationMin,
          onBeginImmersive: onBeginImmersive ?? () {},
          onCancelRoute: onCancelRoute ?? () {},
          onOpenGoogleMaps: onOpenGoogleMaps,
        ),
      ),
    );
  }

  group('NavigationBottomSheet', () {
    testWidgets('shows loading indicator when isLoadingRoute', (tester) async {
      await tester.pumpWidget(buildTestWidget(isLoadingRoute: true));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(CommonConstants.loadingRoute), findsOneWidget);
    });

    testWidgets('shows branch name when not loading', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Taller MotoSpeed'), findsOneWidget);
    });

    testWidgets('displays distance and duration', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('5.2 km'), findsOneWidget);
      expect(
        find.textContaining('12 ${CommonConstants.estimatedTime}'),
        findsOneWidget,
      );
    });

    testWidgets('prefers live distance over active', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(liveDistanceKm: 3.1, liveDurationMin: 8.0),
      );
      expect(find.textContaining('3.1 km'), findsOneWidget);
    });

    testWidgets('shows start button in overview mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text(CommonConstants.startNavigation), findsOneWidget);
    });

    testWidgets('calls onBeginImmersive when start tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(onBeginImmersive: () => tapped = true),
      );
      await tester.tap(find.text(CommonConstants.startNavigation));
      expect(tapped, isTrue);
    });

    testWidgets('shows cancel and google maps in overview', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text(CommonConstants.cancelRoute), findsOneWidget);
      expect(find.text(CommonConstants.openInGoogleMaps), findsOneWidget);
    });

    testWidgets('calls onCancelRoute when cancel tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(onCancelRoute: () => tapped = true),
      );
      await tester.tap(find.text(CommonConstants.cancelRoute));
      expect(tapped, isTrue);
    });

    testWidgets('shows immersive actions in immersive mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(isImmersiveMode: true));
      expect(find.text(CommonConstants.cancelRoute), findsOneWidget);
      expect(find.text(CommonConstants.openInGoogleMaps), findsOneWidget);
      // Start button should NOT be visible in immersive mode
      expect(find.text(CommonConstants.startNavigation), findsNothing);
    });

    testWidgets('shows directions icon', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.directions), findsOneWidget);
    });
  });
}
