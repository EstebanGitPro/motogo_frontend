import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/datasources/category_lines_datasource.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/category_line_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/models/category_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/data/repositories/category_lines_repository_impl.dart';

import 'category_lines_repository_impl_test.mocks.dart';

@GenerateMocks([CategoryLinesDataSource])
void main() {
  late CategoryLinesRepositoryImpl repository;
  late MockCategoryLinesDataSource mockDataSource;

  const testCategoryModels = [
    CategoryModel(name: 'Sport', lineCount: 5),
    CategoryModel(name: 'Scooter', lineCount: 3),
  ];

  const testLineModels = [
    CategoryLineModel(
      model: 'CBR 600',
      brand: 'Honda',
      engineDisplacement: 600,
    ),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<CategoryModel>>>(const Right([]));
    provideDummy<Either<ErrorModel, List<CategoryLineModel>>>(const Right([]));
  });

  setUp(() {
    mockDataSource = MockCategoryLinesDataSource();
    repository = CategoryLinesRepositoryImpl(mockDataSource);
  });

  group('CategoryLinesRepositoryImpl', () {
    group('getCategories', () {
      test('should return list of entities when datasource succeeds', () async {
        when(
          mockDataSource.getCategories(),
        ).thenAnswer((_) async => const Right(testCategoryModels));

        final result = await repository.getCategories();

        expect(result.isRight, isTrue);
        expect(result.right.length, 2);
        expect(result.right[0].name, 'Sport');
        expect(result.right[0].lineCount, 5);
        verify(mockDataSource.getCategories()).called(1);
      });

      test('should return empty list when datasource returns empty', () async {
        when(
          mockDataSource.getCategories(),
        ).thenAnswer((_) async => const Right([]));

        final result = await repository.getCategories();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when datasource fails', () async {
        final errorModel = ErrorModel(
          errorCode: 'CAT_NOT_FOUND',
          message: 'Categorías no encontradas',
        );
        when(
          mockDataSource.getCategories(),
        ).thenAnswer((_) async => Left(errorModel));

        final result = await repository.getCategories();

        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
      });
    });

    group('getCategoryLines', () {
      const testCategory = 'Sport';

      test('should return list of entities when datasource succeeds', () async {
        when(
          mockDataSource.getCategoryLines(testCategory),
        ).thenAnswer((_) async => const Right(testLineModels));

        final result = await repository.getCategoryLines(testCategory);

        expect(result.isRight, isTrue);
        expect(result.right.length, 1);
        expect(result.right[0].model, 'CBR 600');
        verify(mockDataSource.getCategoryLines(testCategory)).called(1);
      });

      test('should return ErrorModel when datasource fails', () async {
        final errorModel = ErrorModel(
          errorCode: 'LINE_ERROR',
          message: 'Error al obtener líneas',
        );
        when(
          mockDataSource.getCategoryLines(testCategory),
        ).thenAnswer((_) async => Left(errorModel));

        final result = await repository.getCategoryLines(testCategory);

        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
      });

      test('should pass category name to datasource', () async {
        const differentCategory = 'Cruiser';
        when(
          mockDataSource.getCategoryLines(differentCategory),
        ).thenAnswer((_) async => const Right([]));

        await repository.getCategoryLines(differentCategory);

        verify(mockDataSource.getCategoryLines(differentCategory)).called(1);
        verifyNever(mockDataSource.getCategoryLines(testCategory));
      });
    });
  });
}
