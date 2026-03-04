import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/services/location_service.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/domain/usecases/get_nearby_branches_usecase.dart';
import 'package:motogo_frontend/src/features/user_home/presentation/bloc/user_home_bloc.dart';

import 'user_home_full_bloc_test.mocks.dart';

@GenerateMocks([GetNearbyBranchesUseCase, LocationService])
void main() {
  late MockGetNearbyBranchesUseCase mockGetNearby;
  late MockLocationService mockLocation;

  const testBranches = <BranchMarkerEntity>[
    BranchMarkerEntity(
      id: 'br-1',
      name: 'Taller Norte',
      type: 'taller',
      latitude: 4.65,
      longitude: -74.05,
      address: 'Calle 100',
      serviceNames: ['Cambio de aceite'],
    ),
    BranchMarkerEntity(
      id: 'br-2',
      name: 'Tienda Sur',
      type: 'tienda',
      latitude: 4.58,
      longitude: -74.10,
    ),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<BranchMarkerEntity>>>(
      const Right(<BranchMarkerEntity>[]),
    );
  });

  setUp(() {
    mockGetNearby = MockGetNearbyBranchesUseCase();
    mockLocation = MockLocationService();
  });

  UserHomeBloc buildBloc() => UserHomeBloc(
    getNearbyBranchesUseCase: mockGetNearby,
    locationService: mockLocation,
  );

  group('UserHomeBloc', () {
    test('initial state is UserHomeInitial', () {
      expect(buildBloc().state, isA<UserHomeInitial>());
    });

    group('InitializeMap', () {
      blocTest<UserHomeBloc, UserHomeState>(
        'emits [Loading, Loaded] and triggers LoadNearbyBranches when location available',
        setUp: () {
          when(mockLocation.getCurrentPosition()).thenAnswer(
            (_) async => Position(
              latitude: 4.61,
              longitude: -74.08,
              timestamp: DateTime.now(),
              accuracy: 10,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            ),
          );
          when(
            mockGetNearby(
              latitude: anyNamed('latitude'),
              longitude: anyNamed('longitude'),
              radiusKm: anyNamed('radiusKm'),
              type: anyNamed('type'),
              brand: anyNamed('brand'),
              displacementRange: anyNamed('displacementRange'),
            ),
          ).thenAnswer((_) async => const Right(testBranches));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const InitializeMap()),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<UserHomeLoading>(),
          isA<UserHomeLoaded>()
              .having((s) => s.userLatitude, 'lat', 4.61)
              .having((s) => s.userLongitude, 'lng', -74.08),
          // LoadNearbyBranches triggered: loading
          isA<UserHomeLoaded>().having(
            (s) => s.isLoadingBranches,
            'loading',
            true,
          ),
          // LoadNearbyBranches complete: branches loaded
          isA<UserHomeLoaded>()
              .having((s) => s.branches.length, 'branches', 2)
              .having((s) => s.isLoadingBranches, 'loading', false),
        ],
      );

      blocTest<UserHomeBloc, UserHomeState>(
        'uses Bogotá defaults when location unavailable',
        setUp: () {
          when(mockLocation.getCurrentPosition()).thenAnswer((_) async => null);
          when(
            mockGetNearby(
              latitude: anyNamed('latitude'),
              longitude: anyNamed('longitude'),
              radiusKm: anyNamed('radiusKm'),
              type: anyNamed('type'),
              brand: anyNamed('brand'),
              displacementRange: anyNamed('displacementRange'),
            ),
          ).thenAnswer((_) async => const Right(<BranchMarkerEntity>[]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const InitializeMap()),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<UserHomeLoading>(),
          isA<UserHomeLoaded>()
              .having((s) => s.locationPermissionDenied, 'denied', true)
              .having((s) => s.userLatitude, 'lat', 4.60971),
          isA<UserHomeLoaded>().having(
            (s) => s.isLoadingBranches,
            'loading',
            true,
          ),
          isA<UserHomeLoaded>().having(
            (s) => s.isLoadingBranches,
            'loading',
            false,
          ),
        ],
      );
    });

    group('SelectBranch & ClearBranchSelection', () {
      blocTest<UserHomeBloc, UserHomeState>(
        'selects and clears a branch',
        setUp: () {
          when(mockLocation.getCurrentPosition()).thenAnswer(
            (_) async => Position(
              latitude: 4.61,
              longitude: -74.08,
              timestamp: DateTime.now(),
              accuracy: 10,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            ),
          );
          when(
            mockGetNearby(
              latitude: anyNamed('latitude'),
              longitude: anyNamed('longitude'),
              radiusKm: anyNamed('radiusKm'),
              type: anyNamed('type'),
              brand: anyNamed('brand'),
              displacementRange: anyNamed('displacementRange'),
            ),
          ).thenAnswer((_) async => const Right(testBranches));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const InitializeMap());
          await Future.delayed(const Duration(milliseconds: 300));
          bloc.add(const SelectBranch('br-1'));
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const ClearBranchSelection());
        },
        skip: 4,
        expect: () => [
          isA<UserHomeLoaded>().having(
            (s) => s.selectedBranchId,
            'selected',
            'br-1',
          ),
          isA<UserHomeLoaded>().having(
            (s) => s.selectedBranchId,
            'selected',
            isNull,
          ),
        ],
      );
    });

    group('SearchBranches', () {
      blocTest<UserHomeBloc, UserHomeState>(
        'updates search query',
        setUp: () {
          when(mockLocation.getCurrentPosition()).thenAnswer(
            (_) async => Position(
              latitude: 4.61,
              longitude: -74.08,
              timestamp: DateTime.now(),
              accuracy: 10,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            ),
          );
          when(
            mockGetNearby(
              latitude: anyNamed('latitude'),
              longitude: anyNamed('longitude'),
              radiusKm: anyNamed('radiusKm'),
              type: anyNamed('type'),
              brand: anyNamed('brand'),
              displacementRange: anyNamed('displacementRange'),
            ),
          ).thenAnswer((_) async => const Right(testBranches));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const InitializeMap());
          await Future.delayed(const Duration(milliseconds: 300));
          bloc.add(const SearchBranches('taller'));
        },
        skip: 4,
        expect: () => [
          isA<UserHomeLoaded>()
              .having((s) => s.searchQuery, 'query', 'taller')
              .having((s) => s.searchResults.length, 'results', 1),
        ],
      );
    });
  });
}
