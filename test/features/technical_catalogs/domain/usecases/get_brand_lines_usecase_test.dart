import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/entities/brand_line_entity.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/repositories/brand_lines_repository.dart';
import 'package:motogo_frontend/src/features/technical_catalogs/domain/usecases/get_brand_lines_usecase.dart';

import 'get_brand_lines_usecase_test.mocks.dart';

@GenerateMocks([BrandLinesRepository])
void main() {
  late GetBrandLinesUseCase useCase;
  late MockBrandLinesRepository mockRepository;

  const testBrandLines = [
    BrandLineEntity(brandName: 'Honda', model: 'CBR 600'),
    BrandLineEntity(brandName: 'Honda', model: 'CBR 1000'),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<BrandLineEntity>>>(const Right([]));
  });

  setUp(() {
    mockRepository = MockBrandLinesRepository();
    useCase = GetBrandLinesUseCase(mockRepository);
  });

  group('GetBrandLinesUseCase', () {
    const testBrandId = 'brand-123';

    group('call', () {
      test(
        'should return list of brand lines when repository succeeds',
        () async {
          // Arrange
          when(
            mockRepository.getBrandLines(testBrandId),
          ).thenAnswer((_) async => const Right(testBrandLines));

          // Act
          final result = await useCase.call(testBrandId);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right, testBrandLines);
          expect(result.right.length, 2);
          verify(mockRepository.getBrandLines(testBrandId)).called(1);
        },
      );

      test('should return empty list when no lines exist', () async {
        // Arrange
        when(
          mockRepository.getBrandLines(testBrandId),
        ).thenAnswer((_) async => const Right([]));

        // Act
        final result = await useCase.call(testBrandId);

        // Assert
        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when repository fails', () async {
        // Arrange
        final errorModel = ErrorModel(
          errorCode: 'BRAND_NOT_FOUND',
          message: 'Marca no encontrada',
        );
        when(
          mockRepository.getBrandLines(testBrandId),
        ).thenAnswer((_) async => Left(errorModel));

        // Act
        final result = await useCase.call(testBrandId);

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockRepository.getBrandLines(testBrandId)).called(1);
      });

      test('should pass brandId to repository correctly', () async {
        // Arrange
        const differentBrandId = 'different-brand-456';
        when(
          mockRepository.getBrandLines(differentBrandId),
        ).thenAnswer((_) async => const Right([]));

        // Act
        await useCase.call(differentBrandId);

        // Assert
        verify(mockRepository.getBrandLines(differentBrandId)).called(1);
        verifyNever(mockRepository.getBrandLines(testBrandId));
      });
    });
  });
}
