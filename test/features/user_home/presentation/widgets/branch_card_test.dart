import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/branch_card.dart';

void main() {
  const workshopBranch = BranchMarkerEntity(
    id: 'b1',
    name: 'Taller MotoSpeed',
    type: 'taller',
    latitude: 4.60971,
    longitude: -74.08175,
    rating: 4.5,
    address: 'Cra 7 #45-10',
    distanceKm: 2.3,
  );

  const storeBranch = BranchMarkerEntity(
    id: 'b2',
    name: 'Tienda Repuestos',
    type: 'tienda',
    latitude: 4.61,
    longitude: -74.08,
  );

  Widget buildTestWidget(
    BranchMarkerEntity branch, {
    VoidCallback? onSeeMore,
    VoidCallback? onNavigate,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: BranchCard(
          branch: branch,
          onSeeMore: onSeeMore ?? () {},
          onNavigate: onNavigate ?? () {},
        ),
      ),
    );
  }

  group('BranchCard', () {
    testWidgets('displays branch name', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.text('Taller MotoSpeed'), findsOneWidget);
    });

    testWidgets('displays address when available', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.text('Cra 7 #45-10'), findsOneWidget);
    });

    testWidgets('hides address when null', (tester) async {
      await tester.pumpWidget(buildTestWidget(storeBranch));
      expect(find.text('Cra 7 #45-10'), findsNothing);
    });

    testWidgets('displays rating when available', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.text('4.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('hides rating when null', (tester) async {
      await tester.pumpWidget(buildTestWidget(storeBranch));
      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('displays distance when available', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.text('2.3 km'), findsOneWidget);
    });

    testWidgets('displays type badge', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.text('Taller'), findsOneWidget);
    });

    testWidgets('displays store type for store branch', (tester) async {
      await tester.pumpWidget(buildTestWidget(storeBranch));
      expect(find.text('Tienda'), findsOneWidget);
    });

    testWidgets('uses workshop icon for workshop type', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.byIcon(Icons.build), findsOneWidget);
    });

    testWidgets('uses store icon for store type', (tester) async {
      await tester.pumpWidget(buildTestWidget(storeBranch));
      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('calls onSeeMore when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(workshopBranch, onSeeMore: () => tapped = true),
      );
      await tester.tap(find.text(CommonConstants.seeMore));
      expect(tapped, isTrue);
    });

    testWidgets('calls onNavigate when directions tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(workshopBranch, onNavigate: () => tapped = true),
      );
      await tester.tap(find.byIcon(Icons.directions));
      expect(tapped, isTrue);
    });

    testWidgets('shows action buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.text(CommonConstants.seeMore), findsOneWidget);
      expect(find.text(CommonConstants.howToGetThere), findsOneWidget);
    });
  });
}
