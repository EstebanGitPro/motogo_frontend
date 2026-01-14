import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/register_branch/domain/usecases/register_branch_usecase.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_event.dart';
import 'package:motogo_frontend/src/features/register_branch/presentation/bloc/register_branch_state.dart';

/// BLoC for managing branch registration state.
class RegisterBranchBloc
    extends Bloc<RegisterBranchEvent, RegisterBranchState> {
  final RegisterBranchUseCase registerBranchUseCase;

  RegisterBranchBloc(this.registerBranchUseCase)
    : super(RegisterBranchInitial()) {
    on<RegisterBranchSubmitted>(_onSubmitted);
    on<RegisterBranchReset>(_onReset);
  }

  Future<void> _onSubmitted(
    RegisterBranchSubmitted event,
    Emitter<RegisterBranchState> emit,
  ) async {
    emit(RegisterBranchLoading());

    final result = await registerBranchUseCase.call(event.branch);

    result.fold(
      (error) => emit(RegisterBranchFailure(error: error)),
      (message) => emit(RegisterBranchSuccess(message: message)),
    );
  }

  void _onReset(RegisterBranchReset event, Emitter<RegisterBranchState> emit) {
    emit(RegisterBranchInitial());
  }
}
