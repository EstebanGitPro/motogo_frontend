import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/repositories/branch_schedule_repository.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_bloc.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_event.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_state.dart';

import 'branch_schedule_full_bloc_test.mocks.dart';

@GenerateMocks([BranchScheduleRepository])
void main() {
  late MockBranchScheduleRepository mockRepository;

  const branchId = 'branch-123';
  final testSchedule = const ScheduleEntity(
    id: 'schedule-1',
    branchId: branchId,
    active: true,
  );

  const testDays = [
    DayEntity(value: 'monday', label: 'Lunes'),
    DayEntity(value: 'tuesday', label: 'Martes'),
  ];

  const testDetail = ScheduleDetailEntity(
    id: 'detail-1',
    scheduleId: 'schedule-1',
    dayOfWeek: 1,
    dayName: 'Lunes',
    openingTime: '08:00',
    closingTime: '18:00',
    isClosed: false,
    active: true,
  );

  const testException = ScheduleExceptionEntity(
    id: 'exc-1',
    scheduleId: 'schedule-1',
    exceptionStartDate: '2026-03-15',
    exceptionEndDate: '2026-03-15',
    exceptionStartDateFormatted: '15 de Marzo, 2026',
    dayName: 'Domingo',
    openingTime: '10:00',
    closingTime: '14:00',
    isClosed: false,
    active: true,
  );

  final testError = ErrorModel(message: 'Error de red');

  setUpAll(() {
    // Provide dummy values for Either types that mockito cannot generate
    provideDummy<Either<ErrorModel, List<DayEntity>>>(
      const Right(<DayEntity>[]),
    );
    provideDummy<Either<ErrorModel, ScheduleEntity?>>(
      Right<ErrorModel, ScheduleEntity?>(null),
    );
    provideDummy<Either<ErrorModel, (ScheduleEntity, String)>>(
      Right((const ScheduleEntity(id: '', branchId: '', active: false), '')),
    );
    provideDummy<Either<ErrorModel, String>>(const Right(''));
    provideDummy<Either<ErrorModel, List<ScheduleDetailEntity>>>(
      const Right(<ScheduleDetailEntity>[]),
    );
    provideDummy<Either<ErrorModel, (ScheduleDetailEntity, String)>>(
      Right((
        const ScheduleDetailEntity(
          id: '',
          scheduleId: '',
          dayOfWeek: 0,
          dayName: '',
          openingTime: '',
          closingTime: '',
          isClosed: false,
          active: false,
        ),
        '',
      )),
    );
    provideDummy<Either<ErrorModel, List<ScheduleExceptionEntity>>>(
      const Right(<ScheduleExceptionEntity>[]),
    );
    provideDummy<Either<ErrorModel, (ScheduleExceptionEntity, String)>>(
      Right((
        const ScheduleExceptionEntity(
          id: '',
          scheduleId: '',
          exceptionStartDate: '',
          exceptionEndDate: '',
          exceptionStartDateFormatted: '',
          dayName: '',
          openingTime: '',
          closingTime: '',
          isClosed: false,
          active: false,
        ),
        '',
      )),
    );
  });

  setUp(() {
    mockRepository = MockBranchScheduleRepository();
  });

  BranchScheduleBloc buildBloc() =>
      BranchScheduleBloc(repository: mockRepository);

  group('BranchScheduleBloc', () {
    test('initial state is BranchScheduleInitial', () {
      expect(buildBloc().state, isA<BranchScheduleInitial>());
    });

    // ========== LoadSchedule ==========

    group('LoadSchedule', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loading, Loaded] when schedule exists',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.getSchedule(branchId),
          ).thenAnswer((_) async => Right(testSchedule));
          when(
            mockRepository.getScheduleDetails(branchId),
          ).thenAnswer((_) async => const Right([testDetail]));
          when(
            mockRepository.getScheduleExceptions(branchId),
          ).thenAnswer((_) async => const Right([testException]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadSchedule(branchId)),
        expect: () => [
          isA<BranchScheduleLoading>(),
          isA<BranchScheduleLoaded>()
              .having((s) => s.schedule, 'schedule', testSchedule)
              .having((s) => s.daysCatalog.length, 'daysCatalog', 2)
              .having((s) => s.details.length, 'details', 1)
              .having((s) => s.exceptions.length, 'exceptions', 1),
        ],
        verify: (_) {
          verify(mockRepository.getDaysCatalog()).called(1);
          verify(mockRepository.getSchedule(branchId)).called(1);
        },
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loading, NotFound] when no schedule exists',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.getSchedule(branchId),
          ).thenAnswer((_) async => const Right(null));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadSchedule(branchId)),
        expect: () => [
          isA<BranchScheduleLoading>(),
          isA<BranchScheduleNotFound>().having(
            (s) => s.daysCatalog.length,
            'daysCatalog',
            2,
          ),
        ],
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loading, Error] when getSchedule fails',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.getSchedule(branchId),
          ).thenAnswer((_) async => Left(testError));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadSchedule(branchId)),
        expect: () => [
          isA<BranchScheduleLoading>(),
          isA<BranchScheduleError>().having(
            (s) => s.message,
            'message',
            'Error de red',
          ),
        ],
      );
    });

    // ========== CreateSchedule ==========

    group('CreateSchedule', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Operating, Loaded] on success',
        setUp: () {
          when(
            mockRepository.createSchedule(branchId),
          ).thenAnswer((_) async => Right((testSchedule, 'Horario creado')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CreateSchedule(branchId)),
        expect: () => [
          isA<BranchScheduleOperating>().having(
            (s) => s.operation,
            'operation',
            'creating',
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.message, 'message', 'Horario creado')
              .having((s) => s.isSuccess, 'isSuccess', true),
        ],
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Operating, Error, NotFound] on failure',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.createSchedule(branchId),
          ).thenAnswer((_) async => Left(testError));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const CreateSchedule(branchId)),
        expect: () => [
          isA<BranchScheduleOperating>(),
          isA<BranchScheduleError>(),
          isA<BranchScheduleNotFound>(),
        ],
      );
    });

    // ========== UpdateSchedule ==========

    group('UpdateSchedule', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Operating, Loaded] on success',
        setUp: () {
          when(
            mockRepository.updateSchedule(branchId, active: true),
          ).thenAnswer(
            (_) async => Right((testSchedule, 'Horario actualizado')),
          );
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const UpdateSchedule(branchId: branchId, active: true)),
        expect: () => [
          isA<BranchScheduleOperating>().having(
            (s) => s.operation,
            'operation',
            'updating',
          ),
          isA<BranchScheduleLoaded>().having(
            (s) => s.message,
            'message',
            'Horario actualizado',
          ),
        ],
      );
    });

    // ========== DeleteSchedule ==========

    group('DeleteSchedule', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Operating, NotFound] with message on success',
        setUp: () {
          when(
            mockRepository.deleteSchedule(branchId),
          ).thenAnswer((_) async => const Right('Horario eliminado'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const DeleteSchedule(branchId)),
        expect: () => [
          isA<BranchScheduleOperating>().having(
            (s) => s.operation,
            'operation',
            'deleting',
          ),
          isA<BranchScheduleNotFound>()
              .having((s) => s.message, 'message', 'Horario eliminado')
              .having((s) => s.isSuccess, 'isSuccess', true),
        ],
      );
    });

    // ========== ToggleScheduleStatus ==========

    group('ToggleScheduleStatus', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Operating(activating), Loaded] when activating',
        setUp: () {
          when(
            mockRepository.activateSchedule(branchId),
          ).thenAnswer((_) async => Right((testSchedule, 'Horario activado')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ToggleScheduleStatus(branchId: branchId, activate: true),
        ),
        expect: () => [
          isA<BranchScheduleOperating>().having(
            (s) => s.operation,
            'operation',
            'activating',
          ),
          isA<BranchScheduleLoaded>().having(
            (s) => s.message,
            'message',
            'Horario activado',
          ),
        ],
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Operating(deactivating), Loaded] when deactivating',
        setUp: () {
          when(mockRepository.deactivateSchedule(branchId)).thenAnswer(
            (_) async => Right((
              testSchedule.copyWith(active: false),
              'Horario desactivado',
            )),
          );
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const ToggleScheduleStatus(branchId: branchId, activate: false),
        ),
        expect: () => [
          isA<BranchScheduleOperating>().having(
            (s) => s.operation,
            'operation',
            'deactivating',
          ),
          isA<BranchScheduleLoaded>(),
        ],
      );
    });

    // ========== ClearMessage ==========

    group('ClearMessage', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'clears message from Loaded state',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.getSchedule(branchId),
          ).thenAnswer((_) async => Right(testSchedule));
          when(
            mockRepository.getScheduleDetails(branchId),
          ).thenAnswer((_) async => const Right([]));
          when(
            mockRepository.getScheduleExceptions(branchId),
          ).thenAnswer((_) async => const Right([]));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(
          schedule: testSchedule,
          message: 'Previous message',
        ),
        act: (bloc) => bloc.add(ClearMessage()),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.message,
            'message',
            isNull,
          ),
        ],
      );
    });

    // ========== CreateScheduleDetail ==========

    group('CreateScheduleDetail', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with loading, Loaded with detail] on success',
        setUp: () {
          when(
            mockRepository.createScheduleDetail(
              branchId,
              dayOfWeek: 1,
              openingTime: '08:00',
              closingTime: '18:00',
              isClosed: false,
            ),
          ).thenAnswer((_) async => const Right((testDetail, 'Franja creada')));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(schedule: testSchedule),
        act: (bloc) => bloc.add(
          const CreateScheduleDetail(
            branchId: branchId,
            dayOfWeek: 1,
            openingTime: '08:00',
            closingTime: '18:00',
          ),
        ),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.details,
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.details.length, 'details', 1)
              .having((s) => s.message, 'message', 'Franja creada')
              .having((s) => s.isSuccess, 'isSuccess', true),
        ],
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with error] on failure',
        setUp: () {
          when(
            mockRepository.createScheduleDetail(
              branchId,
              dayOfWeek: 1,
              openingTime: '08:00',
              closingTime: '18:00',
              isClosed: false,
            ),
          ).thenAnswer((_) async => Left(testError));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(schedule: testSchedule),
        act: (bloc) => bloc.add(
          const CreateScheduleDetail(
            branchId: branchId,
            dayOfWeek: 1,
            openingTime: '08:00',
            closingTime: '18:00',
          ),
        ),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.details,
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.isSuccess, 'isSuccess', false)
              .having((s) => s.message, 'message', 'Error de red'),
        ],
      );
    });

    // ========== UpdateScheduleDetail ==========

    group('UpdateScheduleDetail', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with updated detail] on success',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.getSchedule(branchId),
          ).thenAnswer((_) async => Right(testSchedule));
          when(
            mockRepository.getScheduleDetails(branchId),
          ).thenAnswer((_) async => const Right([testDetail]));
          when(
            mockRepository.getScheduleExceptions(branchId),
          ).thenAnswer((_) async => const Right([]));
          when(
            mockRepository.updateScheduleDetail(
              'detail-1',
              openingTime: '09:00',
              closingTime: '17:00',
              isClosed: false,
            ),
          ).thenAnswer((_) async => const Right('Franja actualizada'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const LoadSchedule(branchId));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const UpdateScheduleDetail(
              branchId: branchId,
              detailId: 'detail-1',
              openingTime: '09:00',
              closingTime: '17:00',
            ),
          );
        },
        skip: 2, // Skip Loading + initial Loaded
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.details,
          ),
          isA<BranchScheduleLoaded>()
              .having(
                (s) => s.details.first.openingTime,
                'openingTime',
                '09:00',
              )
              .having((s) => s.message, 'message', 'Franja actualizada'),
        ],
      );
    });

    // ========== DeleteScheduleDetail ==========

    group('DeleteScheduleDetail', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with empty details] on success',
        setUp: () {
          when(
            mockRepository.deleteScheduleDetail('detail-1'),
          ).thenAnswer((_) async => const Right('Franja eliminada'));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(
          schedule: testSchedule,
          details: const [testDetail],
        ),
        act: (bloc) => bloc.add(
          const DeleteScheduleDetail(branchId: branchId, detailId: 'detail-1'),
        ),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.details,
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.details, 'details', isEmpty)
              .having((s) => s.message, 'message', 'Franja eliminada'),
        ],
      );
    });

    // ========== LoadScheduleExceptions ==========

    group('LoadScheduleExceptions', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with exceptions] on success',
        setUp: () {
          when(
            mockRepository.getScheduleExceptions(branchId),
          ).thenAnswer((_) async => const Right([testException]));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(schedule: testSchedule),
        act: (bloc) => bloc.add(const LoadScheduleExceptions(branchId)),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.exceptions.length,
            'exceptions',
            1,
          ),
        ],
      );
    });

    // ========== CreateScheduleException ==========

    group('CreateScheduleException', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with exception] on success',
        setUp: () {
          when(
            mockRepository.createScheduleException(
              branchId,
              exceptionStartDate: '2026-03-15',
              exceptionEndDate: null,
              openingTime: '10:00',
              closingTime: '14:00',
              isClosed: false,
            ),
          ).thenAnswer(
            (_) async => const Right((testException, 'Excepción creada')),
          );
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(schedule: testSchedule),
        act: (bloc) => bloc.add(
          const CreateScheduleException(
            branchId: branchId,
            exceptionStartDate: '2026-03-15',
            openingTime: '10:00',
            closingTime: '14:00',
          ),
        ),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.exceptions,
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.exceptions.length, 'exceptions', 1)
              .having((s) => s.message, 'message', 'Excepción creada'),
        ],
      );
    });

    // ========== UpdateScheduleException ==========

    group('UpdateScheduleException', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with updated exception] on success',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.getSchedule(branchId),
          ).thenAnswer((_) async => Right(testSchedule));
          when(
            mockRepository.getScheduleDetails(branchId),
          ).thenAnswer((_) async => const Right([]));
          when(
            mockRepository.getScheduleExceptions(branchId),
          ).thenAnswer((_) async => const Right([testException]));
          when(
            mockRepository.updateScheduleException(
              'exc-1',
              openingTime: '11:00',
              closingTime: '15:00',
              isClosed: false,
            ),
          ).thenAnswer((_) async => const Right('Excepción actualizada'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const LoadSchedule(branchId));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const UpdateScheduleException(
              branchId: branchId,
              exceptionId: 'exc-1',
              openingTime: '11:00',
              closingTime: '15:00',
            ),
          );
        },
        skip: 2, // Skip Loading + initial Loaded
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.exceptions,
          ),
          isA<BranchScheduleLoaded>()
              .having(
                (s) => s.exceptions.first.openingTime,
                'openingTime',
                '11:00',
              )
              .having((s) => s.message, 'message', 'Excepción actualizada'),
        ],
      );
    });

    // ========== DeleteScheduleException ==========

    group('DeleteScheduleException', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with empty exceptions] on success',
        setUp: () {
          when(
            mockRepository.deleteScheduleException('exc-1'),
          ).thenAnswer((_) async => const Right('Excepción eliminada'));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(
          schedule: testSchedule,
          exceptions: const [testException],
        ),
        act: (bloc) => bloc.add(
          const DeleteScheduleException(
            branchId: branchId,
            exceptionId: 'exc-1',
          ),
        ),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.exceptions,
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.exceptions, 'exceptions', isEmpty)
              .having((s) => s.message, 'message', 'Excepción eliminada'),
        ],
      );
    });

    // ========== ToggleScheduleExceptionStatus ==========

    group('ToggleScheduleExceptionStatus', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with deactivated exception] when deactivating',
        setUp: () {
          when(
            mockRepository.getDaysCatalog(),
          ).thenAnswer((_) async => const Right(testDays));
          when(
            mockRepository.getSchedule(branchId),
          ).thenAnswer((_) async => Right(testSchedule));
          when(
            mockRepository.getScheduleDetails(branchId),
          ).thenAnswer((_) async => const Right([]));
          when(
            mockRepository.getScheduleExceptions(branchId),
          ).thenAnswer((_) async => const Right([testException]));
          when(
            mockRepository.deactivateScheduleException('exc-1'),
          ).thenAnswer((_) async => const Right('Excepción desactivada'));
        },
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const LoadSchedule(branchId));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(
            const ToggleScheduleExceptionStatus(
              branchId: branchId,
              exceptionId: 'exc-1',
              activate: false,
            ),
          );
        },
        skip: 2, // Skip Loading + initial Loaded
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.exceptions,
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.exceptions.first.active, 'active', false)
              .having((s) => s.message, 'message', 'Excepción desactivada'),
        ],
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with error] on failure',
        setUp: () {
          when(
            mockRepository.activateScheduleException('exc-1'),
          ).thenAnswer((_) async => Left(testError));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(
          schedule: testSchedule,
          exceptions: const [testException],
        ),
        act: (bloc) => bloc.add(
          const ToggleScheduleExceptionStatus(
            branchId: branchId,
            exceptionId: 'exc-1',
            activate: true,
          ),
        ),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.loadingSection,
            'loadingSection',
            LoadingSection.exceptions,
          ),
          isA<BranchScheduleLoaded>()
              .having((s) => s.isSuccess, 'isSuccess', false)
              .having((s) => s.message, 'message', 'Error de red'),
        ],
      );
    });

    // ========== LoadScheduleDetails ==========

    group('LoadScheduleDetails', () {
      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'does nothing when state is not Loaded',
        build: buildBloc,
        act: (bloc) => bloc.add(const LoadScheduleDetails(branchId)),
        expect: () => [],
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with details] on success',
        setUp: () {
          when(
            mockRepository.getScheduleDetails(branchId),
          ).thenAnswer((_) async => const Right([testDetail]));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(schedule: testSchedule),
        act: (bloc) => bloc.add(const LoadScheduleDetails(branchId)),
        expect: () => [
          isA<BranchScheduleLoaded>().having(
            (s) => s.details.length,
            'details',
            1,
          ),
        ],
      );

      blocTest<BranchScheduleBloc, BranchScheduleState>(
        'emits [Loaded with error] on failure',
        setUp: () {
          when(
            mockRepository.getScheduleDetails(branchId),
          ).thenAnswer((_) async => Left(testError));
        },
        build: buildBloc,
        seed: () => BranchScheduleLoaded(schedule: testSchedule),
        act: (bloc) => bloc.add(const LoadScheduleDetails(branchId)),
        expect: () => [
          isA<BranchScheduleLoaded>()
              .having((s) => s.isSuccess, 'isSuccess', false)
              .having((s) => s.message, 'message', 'Error de red'),
        ],
      );
    });
  });
}
