import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/brand_lines_datasource.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/brand_line_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/repositories/brand_lines_repository_impl.dart';

import 'brand_lines_repository_impl_test.mocks.dart';

@GenerateMocks([BrandLinesDataSource])
void main() {
  late BrandLinesRepositoryImpl repository;
  late MockBrandLinesDataSource mockDataSource;

  const testModels = [
    BrandLineModel(brandName: 'Honda', model: 'CBR 600'),
    BrandLineModel(brandName: 'Honda', model: 'CBR 1000'),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<BrandLineModel>>>(const Right([]));
  });

  setUp(() {
    mockDataSource = MockBrandLinesDataSource();
    repository = BrandLinesRepositoryImpl(mockDataSource);
  });

  group('BrandLinesRepositoryImpl', () {
    const testBrandId = 'brand-123';

    group('getBrandLines', () {
      test('should return list of entities when datasource succeeds', () async {
        // Arrange
        when(
          mockDataSource.getBrandLines(testBrandId),
        ).thenAnswer((_) async => const Right(testModels));

        // Act
        final result = await repository.getBrandLines(testBrandId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right.length, 2);
        expect(result.right[0].brandName, 'Honda');
        expect(result.right[0].model, 'CBR 600');
        verify(mockDataSource.getBrandLines(testBrandId)).called(1);
      });

      test('should map models to entities correctly', () async {
        // Arrange
        const singleModel = [BrandLineModel(brandName: 'Yamaha', model: 'R1')];
        when(
          mockDataSource.getBrandLines(testBrandId),
        ).thenAnswer((_) async => const Right(singleModel));

        // Act
        final result = await repository.getBrandLines(testBrandId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right[0].brandName, 'Yamaha');
        expect(result.right[0].model, 'R1');
      });

      test('should return empty list when datasource returns empty', () async {
        // Arrange
        when(
          mockDataSource.getBrandLines(testBrandId),
        ).thenAnswer((_) async => const Right([]));

        // Act
        final result = await repository.getBrandLines(testBrandId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when datasource fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'BRAND_NOT_FOUND',
          message: 'Marca no encontrada',
        );
        when(
          mockDataSource.getBrandLines(testBrandId),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await repository.getBrandLines(testBrandId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockDataSource.getBrandLines(testBrandId)).called(1);
      });

      test('should pass brandId to datasource correctly', () async {
        // Arrange
        const differentBrandId = 'different-brand-456';
        when(
          mockDataSource.getBrandLines(differentBrandId),
        ).thenAnswer((_) async => const Right([]));

        // Act
        await repository.getBrandLines(differentBrandId);

        // Assert
        verify(mockDataSource.getBrandLines(differentBrandId)).called(1);
        verifyNever(mockDataSource.getBrandLines(testBrandId));
      });
    });
  });
}
