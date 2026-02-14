import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/category_lines_repository.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_categories_usecase.dart';

import 'get_categories_usecase_test.mocks.dart';

@GenerateMocks([CategoryLinesRepository])
void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoryLinesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<CategoryEntity>>>(const Right([]));
  });

  setUp(() {
    mockRepository = MockCategoryLinesRepository();
    useCase = GetCategoriesUseCase(mockRepository);
  });

  group('GetCategoriesUseCase', () {
    test('should return categories from repository on success', () async {
      const categories = [
        CategoryEntity(name: 'Adventure', lineCount: 1),
        CategoryEntity(name: 'Enduro', lineCount: 4),
      ];
      when(
        mockRepository.getCategories(),
      ).thenAnswer((_) async => const Right(categories));

      final result = await useCase();

      expect(result.isRight, true);
      expect(result.right, categories);
      verify(mockRepository.getCategories()).called(1);
    });

    test('should return error from repository on failure', () async {
      final error = ErrorModel(message: 'Network error');
      when(mockRepository.getCategories()).thenAnswer((_) async => Left(error));

      final result = await useCase();

      expect(result.isLeft, true);
      expect(result.left.message, 'Network error');
      verify(mockRepository.getCategories()).called(1);
    });
  });
}
