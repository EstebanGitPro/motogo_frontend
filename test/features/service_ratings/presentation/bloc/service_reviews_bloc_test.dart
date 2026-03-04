import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/entities/service_review_entity.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/usecases/get_service_reviews_usecase.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/bloc/service_reviews_bloc.dart';

import 'service_reviews_bloc_test.mocks.dart';

@GenerateMocks([GetServiceReviewsUseCase])
void main() {
  late ServiceReviewsBloc bloc;
  late MockGetServiceReviewsUseCase mockGetServiceReviewsUseCase;

  final testSummary = ServiceReviewSummaryEntity(
    serviceId: 'svc-1',
    serviceName: 'Cambio de aceite',
    averageRating: 4.5,
    totalReviews: 10,
    breakdown: {5: 5, 4: 3, 3: 1, 2: 1, 1: 0},
    reviews: [
      ServiceReviewItemEntity(
        reviewerName: 'Carlos Martinez',
        rating: 5,
        ratedAt: DateTime(2026, 1, 15),
        comment: 'Excelente servicio',
        motorcycleModel: 'Yamaha MT-07',
      ),
    ],
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, ServiceReviewSummaryEntity>>(
      Right(testSummary),
    );
  });

  setUp(() {
    mockGetServiceReviewsUseCase = MockGetServiceReviewsUseCase();
    bloc = ServiceReviewsBloc(
      getServiceReviewsUseCase: mockGetServiceReviewsUseCase,
    );
  });

  tearDown(() => bloc.close());

  group('ServiceReviewsBloc', () {
    test('initial state should be ServiceReviewsInitial', () {
      expect(bloc.state, isA<ServiceReviewsInitial>());
    });

    blocTest<ServiceReviewsBloc, ServiceReviewsState>(
      'emits [Loading, Loaded] when FetchServiceReviews succeeds',
      build: () {
        when(
          mockGetServiceReviewsUseCase.call(any),
        ).thenAnswer((_) async => Right(testSummary));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchServiceReviews(serviceId: 'svc-1')),
      expect: () => [
        isA<ServiceReviewsLoading>(),
        isA<ServiceReviewsLoaded>()
            .having((s) => s.summary.serviceId, 'serviceId', 'svc-1')
            .having((s) => s.summary.averageRating, 'averageRating', 4.5)
            .having((s) => s.summary.reviews.length, 'reviews count', 1),
      ],
      verify: (_) {
        verify(mockGetServiceReviewsUseCase.call('svc-1')).called(1);
      },
    );

    blocTest<ServiceReviewsBloc, ServiceReviewsState>(
      'emits [Loading, Error] when FetchServiceReviews fails',
      build: () {
        when(mockGetServiceReviewsUseCase.call(any)).thenAnswer(
          (_) async => Left(
            ErrorModel(errorCode: 'ERR_001', message: 'Servicio no encontrado'),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(FetchServiceReviews(serviceId: 'svc-999')),
      expect: () => [
        isA<ServiceReviewsLoading>(),
        isA<ServiceReviewsError>().having(
          (s) => s.message,
          'message',
          'Servicio no encontrado',
        ),
      ],
    );
  });
}
