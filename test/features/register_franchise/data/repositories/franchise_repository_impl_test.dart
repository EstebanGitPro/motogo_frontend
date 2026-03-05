import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/datasources/register_franchise_data_source.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/repositories/franchise_repository_impl.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

@GenerateMocks([RegisterFranchiseDataSource])
import 'franchise_repository_impl_test.mocks.dart';

void main() {
  late MockRegisterFranchiseDataSource mockDataSource;
  late FranchiseRepositoryImpl repository;

  const tFranchise = FranchiseEntity(
    name: 'MotoRed',
    description: 'Descripción',
    branchIds: ['branch-1'],
  );

  const tResultModel = FranchiseModel(
    id: 'franchise-xyz',
    name: 'MotoRed',
    description: 'Descripción',
    branchIds: ['branch-1'],
  );

  const tMessage = 'Franquicia creada exitosamente';

  setUpAll(() {
    provideDummy<Either<ErrorModel, (FranchiseModel, String)>>(
      const Right((tResultModel, tMessage)),
    );
  });

  setUp(() {
    mockDataSource = MockRegisterFranchiseDataSource();
    repository = FranchiseRepositoryImpl(mockDataSource);
  });

  group('FranchiseRepositoryImpl', () {
    group('registerFranchise', () {
      test('should return entity on success', () async {
        when(
          mockDataSource.registerFranchise(any),
        ).thenAnswer((_) async => const Right((tResultModel, tMessage)));

        final result = await repository.registerFranchise(tFranchise);

        expect(result.isRight, isTrue);
        final (entity, message) = result.right;
        expect(entity.id, 'franchise-xyz');
        expect(entity.name, 'MotoRed');
        expect(message, tMessage);
        verify(mockDataSource.registerFranchise(any)).called(1);
      });

      test('should return error on failure', () async {
        when(mockDataSource.registerFranchise(any)).thenAnswer(
          (_) async => Left(ErrorModel(message: 'Error del servidor')),
        );

        final result = await repository.registerFranchise(tFranchise);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error del servidor');
      });

      test(
        'should convert entity to model before calling datasource',
        () async {
          when(
            mockDataSource.registerFranchise(any),
          ).thenAnswer((_) async => const Right((tResultModel, tMessage)));

          await repository.registerFranchise(tFranchise);

          final captured =
              verify(
                    mockDataSource.registerFranchise(captureAny),
                  ).captured.single
                  as FranchiseModel;

          expect(captured.name, tFranchise.name);
          expect(captured.description, tFranchise.description);
          expect(captured.branchIds, tFranchise.branchIds);
        },
      );
    });
  });
}
