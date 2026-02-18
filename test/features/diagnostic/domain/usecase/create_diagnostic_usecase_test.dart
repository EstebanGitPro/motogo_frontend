import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/repository/diagnostic_repository.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/usecase/create_diagnostic_usecase.dart';

import 'create_diagnostic_usecase_test.mocks.dart';

@GenerateMocks([DiagnosticRepository])
void main() {
  late CreateDiagnosticUseCase useCase;
  late MockDiagnosticRepository mockRepository;

  final testEntity = DiagnosticEntity(
    id: 'diag-1',
    motorcycleId: 'moto-1',
    problemDescription: 'Motor hace ruido',
    date: DateTime(2026, 1, 15),
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, DiagnosticEntity>>(Right(testEntity));
  });

  setUp(() {
    mockRepository = MockDiagnosticRepository();
    useCase = CreateDiagnosticUseCase(mockRepository);
  });

  group('CreateDiagnosticUseCase', () {
    test('should delegate to repository with all params', () async {
      when(
        mockRepository.createDiagnostic(
          motorcycleId: 'moto-1',
          problemDescription: 'Motor hace ruido',
          branchId: 'branch-1',
        ),
      ).thenAnswer((_) async => Right(testEntity));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        problemDescription: 'Motor hace ruido',
        branchId: 'branch-1',
      );

      expect(result.isRight, isTrue);
      expect(result.right.id, 'diag-1');
      verify(
        mockRepository.createDiagnostic(
          motorcycleId: 'moto-1',
          problemDescription: 'Motor hace ruido',
          branchId: 'branch-1',
        ),
      ).called(1);
    });

    test('should work without optional branchId', () async {
      when(
        mockRepository.createDiagnostic(
          motorcycleId: 'moto-1',
          problemDescription: 'Frenos',
        ),
      ).thenAnswer((_) async => Right(testEntity));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        problemDescription: 'Frenos',
      );

      expect(result.isRight, isTrue);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Error', errorCode: 'ERR');
      when(
        mockRepository.createDiagnostic(
          motorcycleId: 'moto-1',
          problemDescription: 'Test',
        ),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call(
        motorcycleId: 'moto-1',
        problemDescription: 'Test',
      );

      expect(result.isLeft, isTrue);
      expect(result.left, error);
    });
  });
}
