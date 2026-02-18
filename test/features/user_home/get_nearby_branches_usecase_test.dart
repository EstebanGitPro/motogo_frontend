import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/user_home/domain/entities/branch_marker_entity.dart';
import 'package:motogo_frontend/src/features/user_home/domain/repositories/nearby_branches_repository.dart';
import 'package:motogo_frontend/src/features/user_home/domain/usecases/get_nearby_branches_usecase.dart';

import 'get_nearby_branches_usecase_test.mocks.dart';

@GenerateMocks([NearbyBranchesRepository])
void main() {
  late GetNearbyBranchesUseCase useCase;
  late MockNearbyBranchesRepository mockRepository;

  const testBranch = BranchMarkerEntity(
    id: 'branch-1',
    name: 'MotoGo Centro',
    type: 'taller',
    latitude: 4.6097,
    longitude: -74.0817,
    address: 'Calle 50 #30-40',
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<BranchMarkerEntity>>>(const Right([]));
  });

  setUp(() {
    mockRepository = MockNearbyBranchesRepository();
    useCase = GetNearbyBranchesUseCase(mockRepository);
  });

  group('GetNearbyBranchesUseCase', () {
    test('should return list of nearby branches on success', () async {
      when(
        mockRepository.getNearbyBranches(
          latitude: 4.6097,
          longitude: -74.0817,
          radiusKm: 10.0,
        ),
      ).thenAnswer((_) async => const Right([testBranch]));

      final result = await useCase.call(latitude: 4.6097, longitude: -74.0817);

      expect(result.isRight, isTrue);
      expect(result.right.length, 1);
      expect(result.right.first.name, 'MotoGo Centro');
    });

    test('should pass optional filters to repository', () async {
      when(
        mockRepository.getNearbyBranches(
          latitude: 4.6097,
          longitude: -74.0817,
          radiusKm: 5.0,
          type: 'taller',
          brand: 'brand-1',
          displacementRange: 'range-1',
        ),
      ).thenAnswer((_) async => const Right([testBranch]));

      final result = await useCase.call(
        latitude: 4.6097,
        longitude: -74.0817,
        radiusKm: 5.0,
        type: 'taller',
        brand: 'brand-1',
        displacementRange: 'range-1',
      );

      expect(result.isRight, isTrue);
      verify(
        mockRepository.getNearbyBranches(
          latitude: 4.6097,
          longitude: -74.0817,
          radiusKm: 5.0,
          type: 'taller',
          brand: 'brand-1',
          displacementRange: 'range-1',
        ),
      ).called(1);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Sin conexión', errorCode: 'NET');
      when(
        mockRepository.getNearbyBranches(
          latitude: anyNamed('latitude'),
          longitude: anyNamed('longitude'),
          radiusKm: anyNamed('radiusKm'),
        ),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call(latitude: 4.6097, longitude: -74.0817);

      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Sin conexión');
    });
  });
}
