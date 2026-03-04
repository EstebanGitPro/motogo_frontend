import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/service_ratings/domain/usecases/rate_service_item_usecase.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/bloc/service_rating_bloc.dart';

import 'service_rating_bloc_test.mocks.dart';

@GenerateMocks([RateServiceItemUseCase])
void main() {
  late ServiceRatingBloc bloc;
  late MockRateServiceItemUseCase mockRateServiceItemUseCase;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRateServiceItemUseCase = MockRateServiceItemUseCase();
    bloc = ServiceRatingBloc(
      rateServiceItemUseCase: mockRateServiceItemUseCase,
    );
  });

  tearDown(() => bloc.close());

  group('ServiceRatingBloc', () {
    test('initial state should be ServiceRatingInitial', () {
      expect(bloc.state, isA<ServiceRatingInitial>());
    });

    blocTest<ServiceRatingBloc, ServiceRatingState>(
      'emits [Submitting, Success] when SubmitServiceRating succeeds',
      build: () {
        when(mockRateServiceItemUseCase.call(any, any, any)).thenAnswer(
          (_) async => const Right('Calificación registrada exitosamente'),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        SubmitServiceRating(
          completedServiceId: 'cs-123',
          itemId: 'item-456',
          rating: 5,
          comment: 'Excelente servicio',
        ),
      ),
      expect: () => [
        isA<ServiceRatingSubmitting>(),
        isA<ServiceRatingSuccess>().having(
          (s) => s.message,
          'message',
          'Calificación registrada exitosamente',
        ),
      ],
      verify: (_) {
        verify(mockRateServiceItemUseCase.call(any, any, any)).called(1);
      },
    );

    blocTest<ServiceRatingBloc, ServiceRatingState>(
      'emits [Submitting, Error] when SubmitServiceRating fails',
      build: () {
        when(mockRateServiceItemUseCase.call(any, any, any)).thenAnswer(
          (_) async => Left(
            ErrorModel(
              errorCode: 'ERR_RATING_001',
              message: 'Servicio ya calificado',
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        SubmitServiceRating(
          completedServiceId: 'cs-123',
          itemId: 'item-456',
          rating: 3,
        ),
      ),
      expect: () => [
        isA<ServiceRatingSubmitting>(),
        isA<ServiceRatingError>().having(
          (s) => s.message,
          'message',
          'Servicio ya calificado',
        ),
      ],
    );

    blocTest<ServiceRatingBloc, ServiceRatingState>(
      'emits [Submitting, Success] with null comment',
      build: () {
        when(
          mockRateServiceItemUseCase.call(any, any, any),
        ).thenAnswer((_) async => const Right('Calificación registrada'));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SubmitServiceRating(
          completedServiceId: 'cs-123',
          itemId: 'item-789',
          rating: 4,
        ),
      ),
      expect: () => [
        isA<ServiceRatingSubmitting>(),
        isA<ServiceRatingSuccess>(),
      ],
    );
  });

  group('ServiceRatingEvent', () {
    test('SubmitServiceRating stores all fields', () {
      final event = SubmitServiceRating(
        completedServiceId: 'cs-1',
        itemId: 'item-1',
        rating: 5,
        comment: 'Great',
      );

      expect(event.completedServiceId, 'cs-1');
      expect(event.itemId, 'item-1');
      expect(event.rating, 5);
      expect(event.comment, 'Great');
    });

    test('SubmitServiceRating stores null comment', () {
      final event = SubmitServiceRating(
        completedServiceId: 'cs-1',
        itemId: 'item-1',
        rating: 3,
      );

      expect(event.comment, isNull);
    });
  });

  group('ServiceRatingState', () {
    test('ServiceRatingSuccess stores message', () {
      final state = ServiceRatingSuccess(message: 'OK');
      expect(state.message, 'OK');
    });

    test('ServiceRatingError stores message', () {
      final state = ServiceRatingError(message: 'Failed');
      expect(state.message, 'Failed');
    });
  });
}
