import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/catalogs/data/datasources/catalogs_data_source.dart';
import 'package:motogo_frontend/src/core/catalogs/data/models/displacement_range_model.dart';
import 'package:motogo_frontend/src/core/catalogs/data/repositories/catalogs_repository_impl.dart';
import 'package:motogo_frontend/src/core/catalogs/domain/entities/displacement_range_entity.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';

import 'catalogs_repository_impl_test.mocks.dart';

@GenerateMocks([CatalogsDataSource])
void main() {
  late CatalogsRepositoryImpl repository;
  late MockCatalogsDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockCatalogsDataSource();
    repository = CatalogsRepositoryImpl(mockDataSource);

    // Provide dummy values for Either types that mockito can't auto-generate
    provideDummy<Either<ErrorModel, List<DisplacementRangeModel>>>(
      const Right([]),
    );
  });

  group('CatalogsRepositoryImpl', () {
    group('getDisplacementRanges', () {
      test('maps models to entities on success', () async {
        final models = [
          const DisplacementRangeModel(range: 'BAJO'),
          const DisplacementRangeModel(range: 'MEDIO'),
          const DisplacementRangeModel(range: 'ALTO'),
        ];

        when(
          mockDataSource.getDisplacementRanges(),
        ).thenAnswer((_) async => Right(models));

        final result = await repository.getDisplacementRanges();

        expect(result.isRight, isTrue);
        final entities = result.right;
        expect(entities, isA<List<DisplacementRangeEntity>>());
        expect(entities.length, 3);
        expect(entities[0].range, 'BAJO');
        expect(entities[2].range, 'ALTO');
      });

      test('returns ErrorModel on failure', () async {
        final error = ErrorModel(message: 'Error');

        when(
          mockDataSource.getDisplacementRanges(),
        ).thenAnswer((_) async => Left(error));

        final result = await repository.getDisplacementRanges();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<ErrorModel>());
      });
    });
  });
}
