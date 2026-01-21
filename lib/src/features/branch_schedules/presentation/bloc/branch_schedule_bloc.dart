import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/repositories/branch_schedule_repository.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_event.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_state.dart';

/// BLoC for managing branch schedules.
///
/// Handles:
/// - Loading schedule status for a branch
/// - Creating a new schedule
/// - Deleting existing schedule
/// - Activating/Deactivating schedule
class BranchScheduleBloc
    extends Bloc<BranchScheduleEvent, BranchScheduleState> {
  final BranchScheduleRepository _repository;

  BranchScheduleBloc({required BranchScheduleRepository repository})
    : _repository = repository,
      super(BranchScheduleInitial()) {
    on<LoadSchedule>(_onLoadSchedule);
    on<CreateSchedule>(_onCreateSchedule);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<DeleteSchedule>(_onDeleteSchedule);
    on<ToggleScheduleStatus>(_onToggleScheduleStatus);
    on<ClearMessage>(_onClearMessage);
  }

  List<DayEntity> _daysCatalog = [];

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<BranchScheduleState> emit,
  ) async {
    emit(BranchScheduleLoading());

    // Load days catalog in parallel
    final daysResult = await _repository.getDaysCatalog();
    daysResult.fold(
      (error) => _daysCatalog = [],
      (days) => _daysCatalog = days,
    );

    // Load schedule
    final result = await _repository.getSchedule(event.branchId);

    result.fold((error) => emit(BranchScheduleError(error.message)), (
      schedule,
    ) {
      if (schedule == null) {
        emit(BranchScheduleNotFound(daysCatalog: _daysCatalog));
      } else {
        emit(
          BranchScheduleLoaded(schedule: schedule, daysCatalog: _daysCatalog),
        );
      }
    });
  }

  Future<void> _onCreateSchedule(
    CreateSchedule event,
    Emitter<BranchScheduleState> emit,
  ) async {
    emit(const BranchScheduleOperating('creating'));

    final result = await _repository.createSchedule(event.branchId);

    result.fold(
      (error) {
        emit(BranchScheduleError(error.message));
        emit(BranchScheduleNotFound(daysCatalog: _daysCatalog));
      },
      (schedule) {
        emit(
          BranchScheduleLoaded(
            schedule: schedule,
            daysCatalog: _daysCatalog,
            message: ScheduleConstants.scheduleCreated,
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<BranchScheduleState> emit,
  ) async {
    final previousState = state;
    emit(const BranchScheduleOperating('updating'));

    final result = await _repository.updateSchedule(
      event.branchId,
      active: event.active,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (error) {
        emit(BranchScheduleError(error.message));
        // Restore previous state
        if (previousState is BranchScheduleLoaded) {
          emit(previousState);
        } else {
          add(LoadSchedule(event.branchId));
        }
      },
      (schedule) {
        emit(
          BranchScheduleLoaded(
            schedule: schedule,
            daysCatalog: _daysCatalog,
            message: ScheduleConstants.scheduleUpdated,
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteSchedule(
    DeleteSchedule event,
    Emitter<BranchScheduleState> emit,
  ) async {
    emit(const BranchScheduleOperating('deleting'));

    final result = await _repository.deleteSchedule(event.branchId);

    result.fold(
      (error) {
        emit(BranchScheduleError(error.message));
        // Reload to restore state
        add(LoadSchedule(event.branchId));
      },
      (message) {
        emit(
          BranchScheduleNotFound(
            daysCatalog: _daysCatalog,
            message: ScheduleConstants.scheduleDeleted,
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onToggleScheduleStatus(
    ToggleScheduleStatus event,
    Emitter<BranchScheduleState> emit,
  ) async {
    final previousState = state;
    emit(
      BranchScheduleOperating(event.activate ? 'activating' : 'deactivating'),
    );

    final result = event.activate
        ? await _repository.activateSchedule(event.branchId)
        : await _repository.deactivateSchedule(event.branchId);

    result.fold(
      (error) {
        emit(BranchScheduleError(error.message));
        // Restore previous state
        if (previousState is BranchScheduleLoaded) {
          emit(previousState);
        } else {
          add(LoadSchedule(event.branchId));
        }
      },
      (schedule) {
        emit(
          BranchScheduleLoaded(
            schedule: schedule,
            daysCatalog: _daysCatalog,
            message: event.activate
                ? ScheduleConstants.scheduleActivated
                : ScheduleConstants.scheduleDeactivated,
            isSuccess: true,
          ),
        );
      },
    );
  }

  void _onClearMessage(ClearMessage event, Emitter<BranchScheduleState> emit) {
    if (state is BranchScheduleLoaded) {
      emit((state as BranchScheduleLoaded).copyWith(message: null));
    }
  }
}
