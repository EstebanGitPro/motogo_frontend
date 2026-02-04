import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_services/domain/entities/branch_service_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/entities/branch_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_detail/domain/usecases/get_branch_detail_usecase.dart';

part 'branch_detail_event.dart';
part 'branch_detail_state.dart';

/// BLoC for managing branch detail state.
///
/// Handles loading branch information, services, and schedules.
class BranchDetailBloc
    extends Bloc<BranchDetailEvent, BranchDetailState> {
  final GetBranchDetailUseCase _getBranchDetailUseCase;

  BranchDetailBloc({
    required GetBranchDetailUseCase getBranchDetailUseCase,
  }) : _getBranchDetailUseCase = getBranchDetailUseCase,
       super(const BranchDetailInitial()) {
    on<LoadBranchDetail>(_onLoadBranchDetail);
  }

  Future<void> _onLoadBranchDetail(
    LoadBranchDetail event,
    Emitter<BranchDetailState> emit,
  ) async {
    emit(const BranchDetailLoading());

    final result = await _getBranchDetailUseCase(event.branchId);

    result.fold(
      (error) => emit(BranchDetailError(error.message)),
      (fullDetail) => emit(
        BranchDetailLoaded(
          detail: fullDetail.detail,
          services: fullDetail.services,
          schedules: fullDetail.schedules,
          isOpenNow: fullDetail.isOpenNow,
        ),
      ),
    );
  }
}
