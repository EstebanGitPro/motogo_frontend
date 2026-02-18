import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/repositories/branch_detail_repository.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/usecases/get_branch_detail_usecase.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';

import 'get_branch_detail_usecase_test.mocks.dart';

@GenerateMocks([BranchDetailRepository])
void main() {
  late GetBranchDetailUseCase useCase;
  late MockBranchDetailRepository mockRepository;

  const testBranchId = 'branch-123';

  const testDetail = BranchDetailEntity(
    id: testBranchId,
    name: 'Taller Central',
    type: 'taller',
    latitude: 4.6,
    longitude: -74.0,
  );

  setUpAll(() {
    provideDummy<Either<ErrorModel, BranchDetailEntity>>(
      const Right(testDetail),
    );
    provideDummy<Either<ErrorModel, List<BranchServiceEntity>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, List<ScheduleDetailEntity>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, List<ScheduleExceptionEntity>>>(
      const Right([]),
    );
  });

  setUp(() {
    mockRepository = MockBranchDetailRepository();
    useCase = GetBranchDetailUseCase(mockRepository);
  });

  group('GetBranchDetailUseCase', () {
    test('should return BranchFullDetail on success', () async {
      when(
        mockRepository.getDetail(any),
      ).thenAnswer((_) async => const Right(testDetail));
      when(
        mockRepository.getServices(any),
      ).thenAnswer((_) async => const Right([]));
      when(
        mockRepository.getSchedules(any),
      ).thenAnswer((_) async => const Right([]));
      when(
        mockRepository.getExceptions(any),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase.call(testBranchId);

      expect(result.isRight, isTrue);
      expect(result.right.detail.name, 'Taller Central');
      expect(result.right.services, isEmpty);
      expect(result.right.schedules, isEmpty);
      expect(result.right.exceptions, isEmpty);
    });

    test('should return error when detail fails', () async {
      when(mockRepository.getDetail(any)).thenAnswer(
        (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
      );
      when(
        mockRepository.getServices(any),
      ).thenAnswer((_) async => const Right([]));
      when(
        mockRepository.getSchedules(any),
      ).thenAnswer((_) async => const Right([]));
      when(
        mockRepository.getExceptions(any),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase.call(testBranchId);

      expect(result.isLeft, isTrue);
    });

    test(
      'should return detail with empty lists when secondary calls fail',
      () async {
        when(
          mockRepository.getDetail(any),
        ).thenAnswer((_) async => const Right(testDetail));
        when(mockRepository.getServices(any)).thenAnswer(
          (_) async =>
              Left(ErrorModel(errorCode: 'ERR', message: 'Services error')),
        );
        when(mockRepository.getSchedules(any)).thenAnswer(
          (_) async =>
              Left(ErrorModel(errorCode: 'ERR', message: 'Schedules error')),
        );
        when(mockRepository.getExceptions(any)).thenAnswer(
          (_) async =>
              Left(ErrorModel(errorCode: 'ERR', message: 'Exceptions error')),
        );

        final result = await useCase.call(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.detail.name, 'Taller Central');
        expect(result.right.services, isEmpty);
        expect(result.right.schedules, isEmpty);
        expect(result.right.exceptions, isEmpty);
      },
    );
  });

  group('BranchFullDetail', () {
    test('should have correct props', () {
      const fullDetail = BranchFullDetail(
        detail: testDetail,
        services: [],
        schedules: [],
        exceptions: [],
        isOpenNow: false,
      );

      expect(fullDetail.props, hasLength(5));
    });
  });
}
