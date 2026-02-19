import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/data/models/rate_service_request.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/repositories/service_rating_repository.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/usecases/rate_service_item_usecase.dart';

@GenerateMocks([ServiceRatingRepository])
import 'rate_service_item_usecase_test.mocks.dart';

void main() {
  late RateServiceItemUseCase useCase;
  late MockServiceRatingRepository mockRepository;

  setUp(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
    mockRepository = MockServiceRatingRepository();
    useCase = RateServiceItemUseCase(mockRepository);
  });

  group('RateServiceItemUseCase', () {
    const completedServiceId = 'cs-123';
    const itemId = 'item-456';
    const request = RateServiceRequest(rating: 5, comment: 'Excelente');

    test('should delegate to repository and return Right on success', () async {
      when(
        mockRepository.rateServiceItem(completedServiceId, itemId, request),
      ).thenAnswer((_) async => const Right('Calificación registrada'));

      final result = await useCase(completedServiceId, itemId, request);

      expect(result.isRight, isTrue);
      expect(result.right, 'Calificación registrada');
      verify(
        mockRepository.rateServiceItem(completedServiceId, itemId, request),
      ).called(1);
    });

    test('should delegate to repository and return Left on error', () async {
      final error = ErrorModel(
        errorCode: 'ERR_001',
        message: 'Error al calificar',
      );

      when(
        mockRepository.rateServiceItem(completedServiceId, itemId, request),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase(completedServiceId, itemId, request);

      expect(result.isLeft, isTrue);
      expect(result.left.message, 'Error al calificar');
    });
  });
}
