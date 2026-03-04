import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/widgets/search_result_card.dart';

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

  Widget buildTestWidget(BranchMarkerEntity branch, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: SearchResultCard(branch: branch, onTap: onTap ?? () {}),
      ),
    );
  }

  group('SearchResultCard', () {
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

    testWidgets('displays type label', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.text('Taller'), findsOneWidget);
    });

    testWidgets('displays store type for store branch', (tester) async {
      await tester.pumpWidget(buildTestWidget(storeBranch));
      expect(find.text('Tienda'), findsOneWidget);
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

    testWidgets('hides distance when null', (tester) async {
      await tester.pumpWidget(buildTestWidget(storeBranch));
      expect(find.text('2.3 km'), findsNothing);
    });

    testWidgets('uses workshop icon for workshop branch', (tester) async {
      await tester.pumpWidget(buildTestWidget(workshopBranch));
      expect(find.byIcon(Icons.build), findsOneWidget);
    });

    testWidgets('uses store icon for store branch', (tester) async {
      await tester.pumpWidget(buildTestWidget(storeBranch));
      expect(find.byIcon(Icons.store), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestWidget(workshopBranch, onTap: () => tapped = true),
      );
      await tester.tap(find.byType(SearchResultCard));
      expect(tapped, isTrue);
    });
  });
}
