import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/day_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_detail_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_exception_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/models/schedule_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/repositories/branch_schedule_repository_impl.dart';

import 'branch_schedule_repository_impl_test.mocks.dart';

@GenerateMocks([BranchScheduleDataSource])
void main() {
  late BranchScheduleRepositoryImpl repository;
  late MockBranchScheduleDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, ScheduleModel?>>(const Right(null));
    provideDummy<Either<ErrorModel, (ScheduleModel, String)>>(
      Right((const ScheduleModel(id: '', branchId: '', active: true), '')),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
    provideDummy<Either<ErrorModel, List<DayModel>>>(const Right([]));
    provideDummy<Either<ErrorModel, List<ScheduleDetailModel>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, (ScheduleDetailModel, String)>>(
      Right((
        const ScheduleDetailModel(
          id: '',
          scheduleId: '',
          dayOfWeek: 1,
          dayName: '',
          openingTime: '',
          closingTime: '',
          isClosed: false,
          active: true,
        ),
        '',
      )),
    );
    provideDummy<Either<ErrorModel, List<ScheduleExceptionModel>>>(
      const Right([]),
    );
    provideDummy<Either<ErrorModel, (ScheduleExceptionModel, String)>>(
      Right((
        const ScheduleExceptionModel(
          id: '',
          scheduleId: '',
          exceptionStartDate: '',
          exceptionEndDate: '',
          exceptionStartDateFormatted: '',
          dayName: '',
          openingTime: '',
          closingTime: '',
          isClosed: false,
          active: true,
        ),
        '',
      )),
    );
  });

  setUp(() {
    mockDataSource = MockBranchScheduleDataSource();
    repository = BranchScheduleRepositoryImpl(mockDataSource);
  });

  const testBranchId = 'branch-123';

  group('BranchScheduleRepositoryImpl', () {
    // ─── getSchedule ──────────────────────────────────────────────

    test('getSchedule delegates to datasource', () async {
      when(
        mockDataSource.getSchedule(any),
      ).thenAnswer((_) async => const Right(null));

      final result = await repository.getSchedule(testBranchId);

      expect(result.isRight, isTrue);
      expect(result.right, isNull);
      verify(mockDataSource.getSchedule(testBranchId)).called(1);
    });

    // ─── createSchedule ───────────────────────────────────────────

    test('createSchedule delegates and maps result', () async {
      when(mockDataSource.createSchedule(any)).thenAnswer(
        (_) async => Right((
          const ScheduleModel(id: 'sched-1', branchId: 'b1', active: true),
          'Horario creado exitosamente',
        )),
      );

      final result = await repository.createSchedule(testBranchId);

      expect(result.isRight, isTrue);
      expect(result.right.$2, 'Horario creado exitosamente');
    });

    test('createSchedule returns error on failure', () async {
      when(mockDataSource.createSchedule(any)).thenAnswer(
        (_) async => Left(ErrorModel(errorCode: 'ERR', message: 'Error')),
      );

      final result = await repository.createSchedule(testBranchId);

      expect(result.isLeft, isTrue);
    });

    // ─── updateSchedule ───────────────────────────────────────────

    test('updateSchedule delegates to datasource', () async {
      when(
        mockDataSource.updateSchedule(
          any,
          active: anyNamed('active'),
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
        ),
      ).thenAnswer(
        (_) async => Right((
          const ScheduleModel(id: 'sched-1', branchId: 'b1', active: true),
          'ok',
        )),
      );

      final result = await repository.updateSchedule(testBranchId);

      expect(result.isRight, isTrue);
    });

    // ─── deleteSchedule ───────────────────────────────────────────

    test('deleteSchedule delegates to datasource', () async {
      when(
        mockDataSource.deleteSchedule(any),
      ).thenAnswer((_) async => const Right('Horario eliminado'));

      final result = await repository.deleteSchedule(testBranchId);

      expect(result.isRight, isTrue);
      verify(mockDataSource.deleteSchedule(testBranchId)).called(1);
    });

    // ─── activateSchedule ─────────────────────────────────────────

    test('activateSchedule delegates and maps result', () async {
      when(mockDataSource.activateSchedule(any)).thenAnswer(
        (_) async => Right((
          const ScheduleModel(id: 'sched-1', branchId: 'b1', active: true),
          'Horario activado',
        )),
      );

      final result = await repository.activateSchedule(testBranchId);

      expect(result.isRight, isTrue);
      expect(result.right.$2, 'Horario activado');
    });

    // ─── deactivateSchedule ───────────────────────────────────────

    test('deactivateSchedule delegates and maps result', () async {
      when(mockDataSource.deactivateSchedule(any)).thenAnswer(
        (_) async => Right((
          const ScheduleModel(id: 'sched-1', branchId: 'b1', active: false),
          'Horario desactivado',
        )),
      );

      final result = await repository.deactivateSchedule(testBranchId);

      expect(result.isRight, isTrue);
      expect(result.right.$2, 'Horario desactivado');
    });

    // ─── getDaysCatalog ───────────────────────────────────────────

    test('getDaysCatalog delegates to datasource', () async {
      when(
        mockDataSource.getDaysCatalog(),
      ).thenAnswer((_) async => const Right(<DayModel>[]));

      final result = await repository.getDaysCatalog();

      expect(result.isRight, isTrue);
      expect(result.right, isEmpty);
    });

    // ─── getScheduleDetails ───────────────────────────────────────

    test('getScheduleDetails maps models to entities', () async {
      when(mockDataSource.getScheduleDetails(any)).thenAnswer(
        (_) async => const Right([
          ScheduleDetailModel(
            id: 'det-1',
            scheduleId: 'sched-1',
            dayOfWeek: 1,
            dayName: 'Lunes',
            openingTime: '08:00',
            closingTime: '17:00',
            isClosed: false,
            active: true,
          ),
        ]),
      );

      final result = await repository.getScheduleDetails(testBranchId);

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
      expect(result.right[0].dayName, 'Lunes');
    });

    // ─── createScheduleDetail ─────────────────────────────────────

    test('createScheduleDetail maps model to entity', () async {
      when(
        mockDataSource.createScheduleDetail(
          any,
          dayOfWeek: anyNamed('dayOfWeek'),
          openingTime: anyNamed('openingTime'),
          closingTime: anyNamed('closingTime'),
          isClosed: anyNamed('isClosed'),
        ),
      ).thenAnswer(
        (_) async => Right((
          const ScheduleDetailModel(
            id: 'det-1',
            scheduleId: 'sched-1',
            dayOfWeek: 1,
            dayName: 'Lunes',
            openingTime: '08:00',
            closingTime: '17:00',
            isClosed: false,
            active: true,
          ),
          'Franja creada',
        )),
      );

      final result = await repository.createScheduleDetail(
        testBranchId,
        dayOfWeek: 1,
        openingTime: '08:00',
        closingTime: '17:00',
        isClosed: false,
      );

      expect(result.isRight, isTrue);
      expect(result.right.$2, 'Franja creada');
    });

    // ─── updateScheduleDetail ─────────────────────────────────────

    test('updateScheduleDetail delegates to datasource', () async {
      when(
        mockDataSource.updateScheduleDetail(
          any,
          openingTime: anyNamed('openingTime'),
          closingTime: anyNamed('closingTime'),
          isClosed: anyNamed('isClosed'),
        ),
      ).thenAnswer((_) async => const Right('Franja actualizada'));

      final result = await repository.updateScheduleDetail(
        'det-1',
        openingTime: '09:00',
        closingTime: '18:00',
        isClosed: false,
      );

      expect(result.isRight, isTrue);
    });

    // ─── deleteScheduleDetail ─────────────────────────────────────

    test('deleteScheduleDetail delegates to datasource', () async {
      when(
        mockDataSource.deleteScheduleDetail(any),
      ).thenAnswer((_) async => const Right('Franja eliminada'));

      final result = await repository.deleteScheduleDetail('det-1');

      expect(result.isRight, isTrue);
    });

    // ─── getScheduleExceptions ────────────────────────────────────

    test('getScheduleExceptions maps models to entities', () async {
      when(mockDataSource.getScheduleExceptions(any)).thenAnswer(
        (_) async => const Right([
          ScheduleExceptionModel(
            id: 'exc-1',
            scheduleId: 'sched-1',
            exceptionStartDate: '2026-03-01',
            exceptionEndDate: '',
            exceptionStartDateFormatted: '1 de marzo',
            dayName: 'Domingo',
            openingTime: '00:00',
            closingTime: '00:00',
            isClosed: true,
            active: true,
          ),
        ]),
      );

      final result = await repository.getScheduleExceptions(testBranchId);

      expect(result.isRight, isTrue);
      expect(result.right, hasLength(1));
    });

    // ─── createScheduleException ──────────────────────────────────

    test('createScheduleException maps model to entity', () async {
      when(
        mockDataSource.createScheduleException(
          any,
          exceptionStartDate: anyNamed('exceptionStartDate'),
          exceptionEndDate: anyNamed('exceptionEndDate'),
          openingTime: anyNamed('openingTime'),
          closingTime: anyNamed('closingTime'),
          isClosed: anyNamed('isClosed'),
        ),
      ).thenAnswer(
        (_) async => Right((
          const ScheduleExceptionModel(
            id: 'exc-1',
            scheduleId: 'sched-1',
            exceptionStartDate: '2026-03-01',
            exceptionEndDate: '',
            exceptionStartDateFormatted: '1 de marzo',
            dayName: 'Domingo',
            openingTime: '00:00',
            closingTime: '00:00',
            isClosed: true,
            active: true,
          ),
          'Excepción creada',
        )),
      );

      final result = await repository.createScheduleException(
        testBranchId,
        exceptionStartDate: '2026-03-01',
        openingTime: '00:00',
        closingTime: '00:00',
        isClosed: true,
      );

      expect(result.isRight, isTrue);
      expect(result.right.$2, 'Excepción creada');
    });

    // ─── updateScheduleException ──────────────────────────────────

    test('updateScheduleException delegates to datasource', () async {
      when(
        mockDataSource.updateScheduleException(
          any,
          openingTime: anyNamed('openingTime'),
          closingTime: anyNamed('closingTime'),
          isClosed: anyNamed('isClosed'),
        ),
      ).thenAnswer((_) async => const Right('Excepción actualizada'));

      final result = await repository.updateScheduleException(
        'exc-1',
        openingTime: '09:00',
        closingTime: '13:00',
        isClosed: false,
      );

      expect(result.isRight, isTrue);
    });

    // ─── deleteScheduleException ──────────────────────────────────

    test('deleteScheduleException delegates to datasource', () async {
      when(
        mockDataSource.deleteScheduleException(any),
      ).thenAnswer((_) async => const Right('Excepción eliminada'));

      final result = await repository.deleteScheduleException('exc-1');

      expect(result.isRight, isTrue);
    });

    // ─── activateScheduleException ────────────────────────────────

    test('activateScheduleException delegates to datasource', () async {
      when(
        mockDataSource.activateScheduleException(any),
      ).thenAnswer((_) async => const Right('Excepción activada'));

      final result = await repository.activateScheduleException('exc-1');

      expect(result.isRight, isTrue);
    });

    // ─── deactivateScheduleException ──────────────────────────────

    test('deactivateScheduleException delegates to datasource', () async {
      when(
        mockDataSource.deactivateScheduleException(any),
      ).thenAnswer((_) async => const Right('Excepción desactivada'));

      final result = await repository.deactivateScheduleException('exc-1');

      expect(result.isRight, isTrue);
    });
  });
}
