import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/datasource/diagnostic_datasource.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/model/diagnostic_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/data/repository/diagnostic_repository_impl.dart';

import 'diagnostic_repository_impl_test.mocks.dart';

@GenerateMocks([DiagnosticDataSource])
void main() {
  late DiagnosticRepositoryImpl repository;
  late MockDiagnosticDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, DiagnosticResponse>>(
      Right(
        DiagnosticResponse(
          model: const DiagnosticModel(
            id: '',
            motorcycleId: '',
            problemDescription: '',
            date: '',
          ),
          message: '',
        ),
      ),
    );
    provideDummy<Either<ErrorModel, List<DiagnosticModel>>>(const Right([]));
    provideDummy<Either<ErrorModel, DiagnosticModel>>(
      const Right(
        DiagnosticModel(
          id: '',
          motorcycleId: '',
          problemDescription: '',
          date: '',
        ),
      ),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockDiagnosticDataSource();
    repository = DiagnosticRepositoryImpl(mockDataSource);
  });

  const testMotorcycleId = 'moto-123';
  const testDiagnosticId = 'diag-456';

  group('DiagnosticRepositoryImpl', () {
    test('createDiagnostic maps model to entity', () async {
      when(
        mockDataSource.createDiagnostic(
          motorcycleId: anyNamed('motorcycleId'),
          problemDescription: anyNamed('problemDescription'),
          branchId: anyNamed('branchId'),
        ),
      ).thenAnswer(
        (_) async => Right(
          DiagnosticResponse(
            model: const DiagnosticModel(
              id: testDiagnosticId,
              motorcycleId: testMotorcycleId,
              problemDescription: 'Test',
              date: '2026-01-15',
            ),
            message: 'Created',
          ),
        ),
      );

      final result = await repository.createDiagnostic(
        motorcycleId: testMotorcycleId,
        problemDescription: 'Test',
      );

      expect(result.isRight, isTrue);
      expect(result.right.id, testDiagnosticId);
    });

    test('createDiagnostic returns error on failure', () async {
      when(
        mockDataSource.createDiagnostic(
          motorcycleId: anyNamed('motorcycleId'),
          problemDescription: anyNamed('problemDescription'),
          branchId: anyNamed('branchId'),
        ),
      ).thenAnswer(
        (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
      );

      final result = await repository.createDiagnostic(
        motorcycleId: testMotorcycleId,
        problemDescription: 'Test',
      );

      expect(result.isLeft, isTrue);
    });

    test('listDiagnostics maps models to entities', () async {
      when(
        mockDataSource.listDiagnostics(motorcycleId: anyNamed('motorcycleId')),
      ).thenAnswer(
        (_) async => const Right([
          DiagnosticModel(
            id: 'diag-1',
            motorcycleId: testMotorcycleId,
            problemDescription: 'Issue 1',
            date: '2026-01-01',
          ),
        ]),
      );

      final result = await repository.listDiagnostics(
        motorcycleId: testMotorcycleId,
      );

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
    });

    test('getDiagnostic maps model to entity', () async {
      when(
        mockDataSource.getDiagnostic(
          motorcycleId: anyNamed('motorcycleId'),
          diagnosticId: anyNamed('diagnosticId'),
        ),
      ).thenAnswer(
        (_) async => const Right(
          DiagnosticModel(
            id: testDiagnosticId,
            motorcycleId: testMotorcycleId,
            problemDescription: 'Test',
            date: '2026-01-15',
          ),
        ),
      );

      final result = await repository.getDiagnostic(
        motorcycleId: testMotorcycleId,
        diagnosticId: testDiagnosticId,
      );

      expect(result.isRight, isTrue);
      expect(result.right.id, testDiagnosticId);
    });

    test('updateDiagnostic delegates to datasource', () async {
      when(
        mockDataSource.updateDiagnostic(
          motorcycleId: anyNamed('motorcycleId'),
          diagnosticId: anyNamed('diagnosticId'),
          data: anyNamed('data'),
        ),
      ).thenAnswer((_) async => const Right('Updated'));

      final result = await repository.updateDiagnostic(
        motorcycleId: testMotorcycleId,
        diagnosticId: testDiagnosticId,
        data: {'problem_description': 'updated'},
      );

      expect(result.isRight, isTrue);
    });

    test('deleteDiagnostic delegates to datasource', () async {
      when(
        mockDataSource.deleteDiagnostic(
          motorcycleId: anyNamed('motorcycleId'),
          diagnosticId: anyNamed('diagnosticId'),
        ),
      ).thenAnswer((_) async => const Right('Deleted'));

      final result = await repository.deleteDiagnostic(
        motorcycleId: testMotorcycleId,
        diagnosticId: testDiagnosticId,
      );

      expect(result.isRight, isTrue);
    });
  });
}
