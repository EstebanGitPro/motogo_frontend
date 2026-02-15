import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/rating_range_datasource.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rating_range_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/repositories/rating_range_repository_impl.dart';

import 'rating_range_repository_impl_test.mocks.dart';

@GenerateMocks([RatingRangeDataSource])
void main() {
  late RatingRangeRepositoryImpl repository;
  late MockRatingRangeDataSource mockDataSource;

  const testModels = [
    RatingRangeModel(value: 1, label: 'Muy malo'),
    RatingRangeModel(value: 5, label: 'Excelente'),
  ];

  setUpAll(() {
    provideDummy<Either<ErrorModel, List<RatingRangeModel>>>(const Right([]));
  });

  setUp(() {
    mockDataSource = MockRatingRangeDataSource();
    repository = RatingRangeRepositoryImpl(mockDataSource);
  });

  group('RatingRangeRepositoryImpl', () {
    group('getRatingRanges', () {
      test('should return list of entities when datasource succeeds', () async {
        when(
          mockDataSource.getRatingRanges(),
        ).thenAnswer((_) async => const Right(testModels));

        final result = await repository.getRatingRanges();

        expect(result.isRight, isTrue);
        expect(result.right.length, 2);
        expect(result.right[0].value, 1);
        expect(result.right[0].label, 'Muy malo');
        verify(mockDataSource.getRatingRanges()).called(1);
      });

      test('should return empty list when datasource returns empty', () async {
        when(
          mockDataSource.getRatingRanges(),
        ).thenAnswer((_) async => const Right([]));

        final result = await repository.getRatingRanges();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when datasource fails', () async {
        final errorModel = ErrorModel(
          errorCode: 'RATING_ERROR',
          message: 'Error al obtener rangos',
        );
        when(
          mockDataSource.getRatingRanges(),
        ).thenAnswer((_) async => Left(errorModel));

        final result = await repository.getRatingRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, errorModel);
        verify(mockDataSource.getRatingRanges()).called(1);
      });
    });
  });
}
