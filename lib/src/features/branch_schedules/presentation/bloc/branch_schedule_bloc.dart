import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
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
/// - Managing schedule details (time slots)
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
    // Schedule Details handlers
    on<LoadScheduleDetails>(_onLoadScheduleDetails);
    on<CreateScheduleDetail>(_onCreateScheduleDetail);
    on<UpdateScheduleDetail>(_onUpdateScheduleDetail);
    on<DeleteScheduleDetail>(_onDeleteScheduleDetail);
  }

  List<DayEntity> _daysCatalog = [];
  List<ScheduleDetailEntity> _scheduleDetails = [];

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

    await result.fold(
      (error) async => emit(BranchScheduleError(error.message)),
      (schedule) async {
        if (schedule == null) {
          _scheduleDetails = [];
          emit(BranchScheduleNotFound(daysCatalog: _daysCatalog));
        } else {
          // Also load schedule details
          final detailsResult = await _repository.getScheduleDetails(
            event.branchId,
          );
          detailsResult.fold(
            (error) => _scheduleDetails = [],
            (details) => _scheduleDetails = details,
          );

          emit(
            BranchScheduleLoaded(
              schedule: schedule,
              daysCatalog: _daysCatalog,
              details: _scheduleDetails,
            ),
          );
        }
      },
    );
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
        _scheduleDetails = [];
        emit(
          BranchScheduleLoaded(
            schedule: schedule,
            daysCatalog: _daysCatalog,
            details: _scheduleDetails,
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
            details: _scheduleDetails,
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
        _scheduleDetails = [];
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
            details: _scheduleDetails,
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

  // ========== Schedule Details Handlers ==========

  Future<void> _onLoadScheduleDetails(
    LoadScheduleDetails event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    final result = await _repository.getScheduleDetails(event.branchId);

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (details) {
        _scheduleDetails = details;
        emit(currentState.copyWith(details: _scheduleDetails));
      },
    );
  }

  Future<void> _onCreateScheduleDetail(
    CreateScheduleDetail event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    final result = await _repository.createScheduleDetail(
      event.branchId,
      dayOfWeek: event.dayOfWeek,
      openingTime: event.openingTime,
      closingTime: event.closingTime,
      isClosed: event.isClosed,
    );

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (detail) {
        _scheduleDetails = [..._scheduleDetails, detail];
        emit(
          currentState.copyWith(
            details: _scheduleDetails,
            message: ScheduleConstants.timeSlotCreated,
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateScheduleDetail(
    UpdateScheduleDetail event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    final result = await _repository.updateScheduleDetail(
      event.detailId,
      openingTime: event.openingTime,
      closingTime: event.closingTime,
      isClosed: event.isClosed,
    );

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (updatedDetail) {
        _scheduleDetails = _scheduleDetails.map((d) {
          return d.id == event.detailId ? updatedDetail : d;
        }).toList();
        emit(
          currentState.copyWith(
            details: _scheduleDetails,
            message: ScheduleConstants.timeSlotUpdated,
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteScheduleDetail(
    DeleteScheduleDetail event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    final result = await _repository.deleteScheduleDetail(event.detailId);

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (message) {
        _scheduleDetails = _scheduleDetails
            .where((d) => d.id != event.detailId)
            .toList();
        emit(
          currentState.copyWith(
            details: _scheduleDetails,
            message: ScheduleConstants.timeSlotDeleted,
            isSuccess: true,
          ),
        );
      },
    );
  }
}
