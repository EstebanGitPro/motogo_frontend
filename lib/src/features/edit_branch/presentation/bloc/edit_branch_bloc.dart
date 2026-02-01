import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/edit_branch/domain/usecases/update_branch_usecase.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_event.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_state.dart';

/// BLoC for managing branch editing state.
class EditBranchBloc extends Bloc<EditBranchEvent, EditBranchState> {
  final UpdateBranchUseCase _updateBranchUseCase;

  EditBranchBloc({UpdateBranchUseCase? updateBranchUseCase})
    : _updateBranchUseCase =
          updateBranchUseCase ?? InjectorApp.resolve<UpdateBranchUseCase>(),
      super(EditBranchInitial()) {
    on<EditBranchSubmitted>(_onSubmitted);
    on<EditBranchReset>(_onReset);
  }

  Future<void> _onSubmitted(
    EditBranchSubmitted event,
    Emitter<EditBranchState> emit,
  ) async {
    emit(EditBranchLoading());

    final result = await _updateBranchUseCase.call(
      event.branchId,
      event.branch,
    );

    result.fold(
      (error) => emit(EditBranchFailure(error: error)),
      (updatedBranch) => emit(EditBranchSuccess(updatedBranch: updatedBranch)),
    );
  }

  void _onReset(EditBranchReset event, Emitter<EditBranchState> emit) {
    emit(EditBranchInitial());
  }
}
