import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/datasources/service_rating_datasource.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/repositories/service_rating_repository_impl.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';

@GenerateMocks([ServiceRatingDataSource])
import 'service_rating_repository_impl_test.mocks.dart';

void main() {
  late ServiceRatingRepositoryImpl repository;
  late MockServiceRatingDataSource mockDataSource;

  setUp(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
    provideDummy<Either<ErrorModel, ServiceReviewSummaryEntity>>(
      const Right(
        ServiceReviewSummaryEntity(
          serviceId: '',
          serviceName: '',
          averageRating: 0,
          totalReviews: 0,
          breakdown: {},
          reviews: [],
        ),
      ),
    );
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

    group('getServiceReviews', () {
      const branchId = 'branch-abc';
      const serviceId = 'svc-789';

      test(
        'should delegate to dataSource and return Right on success',
        () async {
          const summary = ServiceReviewSummaryEntity(
            serviceId: 'svc-789',
            serviceName: 'Cambio de aceite',
            averageRating: 4.5,
            totalReviews: 10,
            breakdown: {},
            reviews: [],
          );

          when(
            mockDataSource.getServiceReviews(branchId, serviceId),
          ).thenAnswer((_) async => const Right(summary));

          final result = await repository.getServiceReviews(
            branchId,
            serviceId,
          );

          expect(result.isRight, isTrue);
          expect(result.right.serviceId, 'svc-789');
          verify(
            mockDataSource.getServiceReviews(branchId, serviceId),
          ).called(1);
        },
      );

      test('should delegate to dataSource and return Left on error', () async {
        final error = ErrorModel(
          errorCode: 'ERR_001',
          message: 'Error al obtener reseñas',
        );

        when(
          mockDataSource.getServiceReviews(branchId, serviceId),
        ).thenAnswer((_) async => Left(error));

        final result = await repository.getServiceReviews(branchId, serviceId);

        expect(result.isLeft, isTrue);
        expect(result.left.message, 'Error al obtener reseñas');
      });
    });
  });
}
