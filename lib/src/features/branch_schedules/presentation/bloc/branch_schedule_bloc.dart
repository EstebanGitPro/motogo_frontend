import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/schedule_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/day_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';
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
/// - Managing schedule exceptions (HU20-25)
class BranchScheduleBloc
    extends Bloc<BranchScheduleEvent, BranchScheduleState> {
  final BranchScheduleRepository _repository;

  BranchScheduleBloc({BranchScheduleRepository? repository})
    : _repository =
          repository ?? InjectorApp.resolve<BranchScheduleRepository>(),
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
    // Schedule Exceptions handlers (HU20-25)
    on<LoadScheduleExceptions>(_onLoadScheduleExceptions);
    on<CreateScheduleException>(_onCreateScheduleException);
    on<UpdateScheduleException>(_onUpdateScheduleException);
    on<DeleteScheduleException>(_onDeleteScheduleException);
    on<ToggleScheduleExceptionStatus>(_onToggleScheduleExceptionStatus);
  }

  List<DayEntity> _daysCatalog = [];
  List<ScheduleDetailEntity> _scheduleDetails = [];
  List<ScheduleExceptionEntity> _scheduleExceptions = [];

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
          _scheduleExceptions = [];
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

          // Also load schedule exceptions
          final exceptionsResult = await _repository.getScheduleExceptions(
            event.branchId,
          );
          exceptionsResult.fold(
            (error) => _scheduleExceptions = [],
            (exceptions) => _scheduleExceptions = exceptions,
          );

          emit(
            BranchScheduleLoaded(
              schedule: schedule,
              daysCatalog: _daysCatalog,
              details: _scheduleDetails,
              exceptions: _scheduleExceptions,
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
      (record) {
        final (schedule, message) = record;
        _scheduleDetails = [];
        _scheduleExceptions = [];
        emit(
          BranchScheduleLoaded(
            schedule: schedule,
            daysCatalog: _daysCatalog,
            details: _scheduleDetails,
            exceptions: _scheduleExceptions,
            message: message, // Use backend message
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
            exceptions: _scheduleExceptions,
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
        _scheduleExceptions = [];
        emit(
          BranchScheduleNotFound(
            daysCatalog: _daysCatalog,
            message: message, // Use backend message
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
      (record) {
        final (schedule, message) = record;
        emit(
          BranchScheduleLoaded(
            schedule: schedule,
            daysCatalog: _daysCatalog,
            details: _scheduleDetails,
            exceptions: _scheduleExceptions,
            message: message, // Use backend message
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

    // Emit loading state for details section
    emit(currentState.copyWith(loadingSection: LoadingSection.details));

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

    // Emit loading state for details section
    emit(currentState.copyWith(loadingSection: LoadingSection.details));

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
      (message) {
        // Backend returns success message without updated entity,
        // so we update the detail locally with the event values
        _scheduleDetails = _scheduleDetails.map((d) {
          if (d.id == event.detailId) {
            return d.copyWith(
              openingTime: event.openingTime,
              closingTime: event.closingTime,
              isClosed: event.isClosed,
            );
          }
          return d;
        }).toList();
        emit(
          currentState.copyWith(
            details: _scheduleDetails,
            message: message, // Use backend message
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

    // Emit loading state for details section
    emit(currentState.copyWith(loadingSection: LoadingSection.details));

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
            message: message, // Use backend message
            isSuccess: true,
          ),
        );
      },
    );
  }

  // ========== Schedule Exceptions Handlers (HU20-25) ==========

  Future<void> _onLoadScheduleExceptions(
    LoadScheduleExceptions event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    final result = await _repository.getScheduleExceptions(event.branchId);

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (exceptions) {
        _scheduleExceptions = exceptions;
        emit(currentState.copyWith(exceptions: _scheduleExceptions));
      },
    );
  }

  Future<void> _onCreateScheduleException(
    CreateScheduleException event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    // Emit loading state for exceptions section
    emit(currentState.copyWith(loadingSection: LoadingSection.exceptions));

    final result = await _repository.createScheduleException(
      event.branchId,
      exceptionStartDate: event.exceptionStartDate,
      exceptionEndDate: event.exceptionEndDate,
      openingTime: event.openingTime,
      closingTime: event.closingTime,
      isClosed: event.isClosed,
    );

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (record) {
        final (exception, message) = record;
        _scheduleExceptions = [..._scheduleExceptions, exception];
        emit(
          currentState.copyWith(
            exceptions: _scheduleExceptions,
            message: message, // Use backend message
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateScheduleException(
    UpdateScheduleException event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    // Emit loading state for exceptions section
    emit(currentState.copyWith(loadingSection: LoadingSection.exceptions));

    final result = await _repository.updateScheduleException(
      event.exceptionId,
      openingTime: event.openingTime,
      closingTime: event.closingTime,
      isClosed: event.isClosed,
    );

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (message) {
        // Backend returns success message without updated entity,
        // so we update the exception locally with the event values
        _scheduleExceptions = _scheduleExceptions.map((e) {
          if (e.id == event.exceptionId) {
            return e.copyWith(
              openingTime: event.openingTime,
              closingTime: event.closingTime,
              isClosed: event.isClosed,
            );
          }
          return e;
        }).toList();
        emit(
          currentState.copyWith(
            exceptions: _scheduleExceptions,
            message: message, // Use backend message instead of local constant
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onDeleteScheduleException(
    DeleteScheduleException event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    // Emit loading state for exceptions section
    emit(currentState.copyWith(loadingSection: LoadingSection.exceptions));

    final result = await _repository.deleteScheduleException(event.exceptionId);

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (message) {
        _scheduleExceptions = _scheduleExceptions
            .where((e) => e.id != event.exceptionId)
            .toList();
        emit(
          currentState.copyWith(
            exceptions: _scheduleExceptions,
            message: message, // Use backend message
            isSuccess: true,
          ),
        );
      },
    );
  }

  Future<void> _onToggleScheduleExceptionStatus(
    ToggleScheduleExceptionStatus event,
    Emitter<BranchScheduleState> emit,
  ) async {
    if (state is! BranchScheduleLoaded) return;

    final currentState = state as BranchScheduleLoaded;

    // Emit loading state for exceptions section
    emit(currentState.copyWith(loadingSection: LoadingSection.exceptions));

    final result = event.activate
        ? await _repository.activateScheduleException(event.exceptionId)
        : await _repository.deactivateScheduleException(event.exceptionId);

    result.fold(
      (error) {
        emit(currentState.copyWith(message: error.message, isSuccess: false));
      },
      (message) {
        // Backend returns success message without updated entity,
        // so we update the exception locally with the event value
        _scheduleExceptions = _scheduleExceptions.map((e) {
          if (e.id == event.exceptionId) {
            return e.copyWith(active: event.activate);
          }
          return e;
        }).toList();
        emit(
          currentState.copyWith(
            exceptions: _scheduleExceptions,
            message: message, // Use backend message
            isSuccess: true,
          ),
        );
      },
    );
  }
}
