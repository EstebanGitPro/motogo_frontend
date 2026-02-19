import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/service_rating_datasource.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/repositories/service_rating_repository_impl.dart';

@GenerateMocks([ServiceRatingDataSource])
import 'service_rating_repository_impl_test.mocks.dart';

void main() {
  late ServiceRatingRepositoryImpl repository;
  late MockServiceRatingDataSource mockDataSource;

  setUp(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
    mockDataSource = MockServiceRatingDataSource();
    repository = ServiceRatingRepositoryImpl(mockDataSource);
  });

  group('ServiceRatingRepositoryImpl', () {
    group('rateServiceItem', () {
      const completedServiceId = 'cs-123';
      const itemId = 'item-456';
      const request = RateServiceRequest(rating: 4, comment: 'Buen servicio');

      test(
        'should delegate to dataSource and return Right on success',
        () async {
          when(
            mockDataSource.rateServiceItem(completedServiceId, itemId, request),
          ).thenAnswer((_) async => const Right('Calificación registrada'));

          final result = await repository.rateServiceItem(
            completedServiceId,
            itemId,
            request,
          );

          expect(result.isRight, isTrue);
          expect(result.right, 'Calificación registrada');
          verify(
            mockDataSource.rateServiceItem(completedServiceId, itemId, request),
          ).called(1);
        },
      );

      test('should delegate to dataSource and return Left on error', () async {
        final error = ErrorModel(
          errorCode: 'ERR_001',
          message: 'Error al calificar',
        );

        when(
          mockDataSource.rateServiceItem(completedServiceId, itemId, request),
        ).thenAnswer((_) async => Left(error));

        final result = await repository.rateServiceItem(
          completedServiceId,
          itemId,
          request,
        );

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error al calificar');
      });
    });
  });
}
