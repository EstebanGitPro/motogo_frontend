import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/repositories/service_rating_repository.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/usecases/get_service_reviews_usecase.dart';

@GenerateMocks([ServiceRatingRepository])
import 'get_service_reviews_usecase_test.mocks.dart';

void main() {
  late GetServiceReviewsUseCase useCase;
  late MockServiceRatingRepository mockRepository;

  setUp(() {
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
    mockRepository = MockServiceRatingRepository();
    useCase = GetServiceReviewsUseCase(mockRepository);
  });

  group('GetServiceReviewsUseCase', () {
    const serviceId = 'svc-123';

    test('should delegate to repository and return Right on success', () async {
      const summary = ServiceReviewSummaryEntity(
        serviceId: 'svc-123',
        serviceName: 'Cambio de aceite',
        averageRating: 4.5,
        totalReviews: 10,
        breakdown: {5: 5, 4: 3, 3: 1, 2: 1, 1: 0},
        reviews: [],
      );

      when(
        mockRepository.getServiceReviews(serviceId),
      ).thenAnswer((_) async => const Right(summary));

      final result = await useCase(serviceId);

      expect(result.isRight, isTrue);
      expect(result.right.serviceId, 'svc-123');
      expect(result.right.averageRating, 4.5);
      verify(mockRepository.getServiceReviews(serviceId)).called(1);
    });

    test('should delegate to repository and return Left on error', () async {
      final error = ErrorModel(
        errorCode: 'ERR_001',
        message: 'Error al obtener reseñas',
      );

      when(
        mockRepository.getServiceReviews(serviceId),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase(serviceId);

      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Error al obtener reseñas');
    });
  });
}
