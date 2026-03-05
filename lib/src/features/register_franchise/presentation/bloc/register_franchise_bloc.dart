import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/usecases/register_franchise_usecase.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_event.dart';
import 'package:motogo_frontend/src/features/register_franchise/presentation/bloc/register_franchise_state.dart';

/// BLoC for managing franchise registration state.
class RegisterFranchiseBloc
    extends Bloc<RegisterFranchiseEvent, RegisterFranchiseState> {
  final RegisterFranchiseUseCase _registerFranchiseUseCase;

  RegisterFranchiseBloc({
    required RegisterFranchiseUseCase registerFranchiseUseCase,
  }) : _registerFranchiseUseCase = registerFranchiseUseCase,
       super(const RegisterFranchiseInitial()) {
    on<SubmitFranchise>(_onSubmitFranchise);
    on<ResetFranchiseForm>(_onResetForm);
  }

  Future<void> _onSubmitFranchise(
    SubmitFranchise event,
    Emitter<RegisterFranchiseState> emit,
  ) async {
    emit(const RegisterFranchiseLoading());

    final result = await _registerFranchiseUseCase(event.franchise);

    result.fold(
      (error) => emit(
        RegisterFranchiseError(
          code: error.errorCode ?? 'UNKNOWN',
          message: error.message,
        ),
      ),
      (record) => emit(
        RegisterFranchiseSuccess(franchise: record.$1, message: record.$2),
      ),
    );
  }

  void _onResetForm(
    ResetFranchiseForm event,
    Emitter<RegisterFranchiseState> emit,
  ) {
    emit(const RegisterFranchiseInitial());
  }
}
