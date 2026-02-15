import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/category_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/category_lines_repository.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_category_lines_usecase.dart';

import 'get_category_lines_usecase_test.mocks.dart';

@GenerateMocks([CategoryLinesRepository])
void main() {
  late GetCategoryLinesUseCase useCase;
  late MockCategoryLinesRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<CategoryLineEntity>>>(const Right([]));
  });

  setUp(() {
    mockRepository = MockCategoryLinesRepository();
    useCase = GetCategoryLinesUseCase(mockRepository);
  });

  group('GetCategoryLinesUseCase', () {
    const categoryName = 'Adventure';

    test('should return category lines from repository on success', () async {
      const lines = [
        CategoryLineEntity(
          model: 'Adventure 390',
          brand: 'KTM',
          engineDisplacement: 373,
        ),
      ];
      when(
        mockRepository.getCategoryLines(categoryName),
      ).thenAnswer((_) async => const Right(lines));

      final result = await useCase(categoryName);

      expect(result.isRight, true);
      expect(result.right, lines);
      verify(mockRepository.getCategoryLines(categoryName)).called(1);
    });

    test('should return error from repository on failure', () async {
      final error = ErrorModel(message: 'Network error');
      when(
        mockRepository.getCategoryLines(categoryName),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase(categoryName);

      expect(result.isLeft, true);
      expect(result.left.message, 'Network error');
      verify(mockRepository.getCategoryLines(categoryName)).called(1);
    });
  });
}
