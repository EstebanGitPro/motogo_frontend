import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/datasource/diagnostic_permission_datasource.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/model/diagnostic_permission_model.dart';
import 'package:motogo_frontend/src/features/diagnostic_permission/data/repository/diagnostic_permission_repository_impl.dart';

import 'diagnostic_permission_repository_impl_test.mocks.dart';

@GenerateMocks([DiagnosticPermissionDataSource])
void main() {
  late DiagnosticPermissionRepositoryImpl repository;
  late MockDiagnosticPermissionDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, PermissionGrantResponse>>(
      Right(
        PermissionGrantResponse(
          model: const DiagnosticPermissionModel(
            id: '',
            motorcycleId: '',
            branchId: '',
            grantedAt: '',
          ),
          message: '',
        ),
      ),
    );
    provideDummy<Either<ErrorModel, List<DiagnosticPermissionModel>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockDiagnosticPermissionDataSource();
    repository = DiagnosticPermissionRepositoryImpl(mockDataSource);
  });

  const testMotorcycleId = 'moto-123';
  const testBranchId = 'branch-456';

  group('DiagnosticPermissionRepositoryImpl', () {
    test('grantPermission maps response to PermissionGrantResult', () async {
      when(
        mockDataSource.grantPermission(
          motorcycleId: anyNamed('motorcycleId'),
          branchId: anyNamed('branchId'),
          active: anyNamed('active'),
        ),
      ).thenAnswer(
        (_) async => Right(
          PermissionGrantResponse(
            model: const DiagnosticPermissionModel(
              id: 'perm-1',
              motorcycleId: testMotorcycleId,
              branchId: testBranchId,
              active: true,
              grantedAt: '2026-01-15',
            ),
            message: 'Permiso otorgado',
          ),
        ),
      );

      final result = await repository.grantPermission(
        motorcycleId: testMotorcycleId,
        branchId: testBranchId,
        active: true,
      );

      expect(result.isRight, isTrue);
      expect(result.right.message, 'Permiso otorgado');
    });

    test('grantPermission returns error on failure', () async {
      when(
        mockDataSource.grantPermission(
          motorcycleId: anyNamed('motorcycleId'),
          branchId: anyNamed('branchId'),
          active: anyNamed('active'),
        ),
      ).thenAnswer(
        (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
      );

      final result = await repository.grantPermission(
        motorcycleId: testMotorcycleId,
        branchId: testBranchId,
        active: true,
      );

      expect(result.isLeft, isTrue);
    });

    test('listPermissions maps models to entities', () async {
      when(
        mockDataSource.listPermissions(motorcycleId: anyNamed('motorcycleId')),
      ).thenAnswer(
        (_) async => const Right([
          DiagnosticPermissionModel(
            id: 'perm-1',
            motorcycleId: testMotorcycleId,
            branchId: testBranchId,
            active: true,
            grantedAt: '2026-01-15',
          ),
        ]),
      );

      final result = await repository.listPermissions(
        motorcycleId: testMotorcycleId,
      );

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
    });

    test('listPermissions returns error on failure', () async {
      when(
        mockDataSource.listPermissions(motorcycleId: anyNamed('motorcycleId')),
      ).thenAnswer(
        (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
      );

      final result = await repository.listPermissions(
        motorcycleId: testMotorcycleId,
      );

      expect(result.isLeft, isTrue);
    });

    test('revokePermission delegates to datasource', () async {
      when(
        mockDataSource.revokePermission(
          motorcycleId: anyNamed('motorcycleId'),
          branchId: anyNamed('branchId'),
        ),
      ).thenAnswer((_) async => const Right('Revoked'));

      final result = await repository.revokePermission(
        motorcycleId: testMotorcycleId,
        branchId: testBranchId,
      );

      expect(result.isRight, isTrue);
    });
  });
}
