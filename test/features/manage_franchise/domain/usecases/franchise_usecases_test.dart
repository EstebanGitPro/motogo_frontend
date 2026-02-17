import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/manage_franchise/data/datasources/franchise_data_source.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/register_franchise/data/models/franchise_model.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

import 'franchise_usecases_test.mocks.dart';

@GenerateMocks([FranchiseDataSource])
void main() {
  late MockFranchiseDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, FranchiseEntity>>(
      Right(FranchiseModel.fromJson(const {'name': 'Test'})),
    );
    provideDummy<Either<ErrorModel, FranchiseModel>>(
      Right(FranchiseModel.fromJson(const {'name': 'Test'})),
    );
    provideDummy<Either<ErrorModel, List<FranchiseModel>>>(const Right([]));
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockFranchiseDataSource();
  });

  group('GetFranchiseUseCase', () {
    test('should delegate to datasource', () async {
      final useCase = GetFranchiseUseCase(mockDataSource);
      when(mockDataSource.getFranchise(any)).thenAnswer(
        (_) async =>
            Right(FranchiseModel.fromJson(const {'id': 'f1', 'name': 'Test'})),
      );

      final result = await useCase.call('f1');

      expect(result.isRight, isTrue);
      verify(mockDataSource.getFranchise('f1')).called(1);
    });
  });

  group('ListFranchisesUseCase', () {
    test('should return list of entities on success', () async {
      final useCase = ListFranchisesUseCase(mockDataSource);
      when(mockDataSource.listFranchises()).thenAnswer(
        (_) async => Right([
          FranchiseModel.fromJson({'name': 'F1'}),
        ]),
      );

      final result = await useCase.call();

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
    });

    test('should return error on failure', () async {
      final useCase = ListFranchisesUseCase(mockDataSource);
      when(mockDataSource.listFranchises()).thenAnswer(
        (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
      );

      final result = await useCase.call();

      expect(result.isLeft, isTrue);
    });
  });

  group('UpdateFranchiseUseCase', () {
    test('should delegate to datasource with model', () async {
      final useCase = UpdateFranchiseUseCase(mockDataSource);
      when(mockDataSource.updateFranchise(any, any)).thenAnswer(
        (_) async => Right(
          FranchiseModel.fromJson(const {'id': 'f1', 'name': 'Updated'}),
        ),
      );

      final result = await useCase.call(
        'f1',
        const FranchiseEntity(name: 'Updated'),
      );

      expect(result.isRight, isTrue);
      verify(mockDataSource.updateFranchise('f1', any)).called(1);
    });
  });

  group('DeleteFranchiseUseCase', () {
    test('should delegate to datasource', () async {
      final useCase = DeleteFranchiseUseCase(mockDataSource);
      when(
        mockDataSource.deleteFranchise(any),
      ).thenAnswer((_) async => const Right('Deleted'));

      final result = await useCase.call('f1');

      expect(result.isRight, isTrue);
      verify(mockDataSource.deleteFranchise('f1')).called(1);
    });
  });

  group('LinkBranchToFranchiseUseCase', () {
    test('should delegate to datasource', () async {
      final useCase = LinkBranchToFranchiseUseCase(mockDataSource);
      when(
        mockDataSource.linkBranch(any, any),
      ).thenAnswer((_) async => const Right('Linked'));

      final result = await useCase.call('b1', 'f1');

      expect(result.isRight, isTrue);
      verify(mockDataSource.linkBranch('b1', 'f1')).called(1);
    });
  });

  group('UnlinkBranchFromFranchiseUseCase', () {
    test('should delegate to datasource', () async {
      final useCase = UnlinkBranchFromFranchiseUseCase(mockDataSource);
      when(
        mockDataSource.unlinkBranch(any, any),
      ).thenAnswer((_) async => const Right('Unlinked'));

      final result = await useCase.call('b1', 'f1');

      expect(result.isRight, isTrue);
      verify(mockDataSource.unlinkBranch('b1', 'f1')).called(1);
    });
  });
}
