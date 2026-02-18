import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/diagnostic_permission_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/entity/permission_grant_result.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/repository/diagnostic_permission_repository.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/grant_permission_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/list_permissions_usecase.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/domain/usecase/revoke_permission_usecase.dart';

import 'diagnostic_permission_usecases_test.mocks.dart';

@GenerateMocks([DiagnosticPermissionRepository])
void main() {
  late MockDiagnosticPermissionRepository mockRepository;

  final testPermission = DiagnosticPermissionEntity(
    id: 'perm-1',
    motorcycleId: 'moto-1',
    branchId: 'branch-1',
    branchName: 'MotoGo Centro',
    grantedAt: DateTime(2026, 1, 15),
  );
  final testGrantResult = PermissionGrantResult(
    permission: testPermission,
    message: 'Permiso otorgado',
  );
  final errorModel = ErrorModel(message: 'Error', errorCode: 'ERR');

  setUpAll(() {
    provideDummy<Either<ErrorModel, PermissionGrantResult>>(
      Right(testGrantResult),
    );
    provideDummy<Either<ErrorModel, List<DiagnosticPermissionEntity>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockDiagnosticPermissionRepository();
  });

  group('GrantPermissionUseCase', () {
    late GrantPermissionUseCase useCase;

    setUp(() {
      useCase = GrantPermissionUseCase(mockRepository);
    });

    test('should return PermissionGrantResult on success', () async {
      when(
        mockRepository.grantPermission(
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
          active: true,
        ),
      ).thenAnswer((_) async => Right(testGrantResult));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchId: 'branch-1',
        active: true,
      );

      expect(result.isRight, isTrue);
      expect(result.right.message, 'Permiso otorgado');
      verify(
        mockRepository.grantPermission(
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
          active: true,
        ),
      ).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.grantPermission(
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
          active: true,
        ),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchId: 'branch-1',
        active: true,
      );

      expect(result.isLeft, isTrue);
      expect(result.left, errorModel);
    });
  });

  group('ListPermissionsUseCase', () {
    late ListPermissionsUseCase useCase;

    setUp(() {
      useCase = ListPermissionsUseCase(mockRepository);
    });

    test('should return list of permissions on success', () async {
      when(
        mockRepository.listPermissions(motorcycleId: 'moto-1'),
      ).thenAnswer((_) async => Right([testPermission]));

      final result = await useCase.call(motorcycleId: 'moto-1');

      expect(result.isRight, isTrue);
      expect(result.right.length, 1);
      verify(mockRepository.listPermissions(motorcycleId: 'moto-1')).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.listPermissions(motorcycleId: 'moto-1'),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(motorcycleId: 'moto-1');

      expect(result.isLeft, isTrue);
    });
  });

  group('RevokePermissionUseCase', () {
    late RevokePermissionUseCase useCase;

    setUp(() {
      useCase = RevokePermissionUseCase(mockRepository);
    });

    test('should return success message on success', () async {
      when(
        mockRepository.revokePermission(
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
        ),
      ).thenAnswer((_) async => const Right('Permiso revocado'));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchId: 'branch-1',
      );

      expect(result.isRight, isTrue);
      expect(result.right, 'Permiso revocado');
      verify(
        mockRepository.revokePermission(
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
        ),
      ).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.revokePermission(
          motorcycleId: 'moto-1',
          branchId: 'branch-1',
        ),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        branchId: 'branch-1',
      );

      expect(result.isLeft, isTrue);
    });
  });
}
