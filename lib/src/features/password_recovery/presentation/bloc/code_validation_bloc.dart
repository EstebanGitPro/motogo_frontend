import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/validate_code_usecase.dart';

part 'code_validation_event.dart';
part 'code_validation_state.dart';

class CodeValidationBloc
    extends Bloc<CodeValidationEvent, CodeValidationState> {
  CodeValidationBloc() : super(CodeValidationInitial()) {
    final ValidateCodeUseCase validateCodeUseCase =
        InjectorApp.resolve<ValidateCodeUseCase>();

    on<CodeValidationSubmitted>(
      (event, emit) =>
          _onCodeValidationSubmitted(event, emit, validateCodeUseCase),
    );
  }

  Future<void> _onCodeValidationSubmitted(
    CodeValidationSubmitted event,
    Emitter<CodeValidationState> emit,
    ValidateCodeUseCase validateCodeUseCase,
  ) async {
    emit(CodeValidationLoading());

    final result = await validateCodeUseCase.call(event.code);

    result.fold(
      (failure) => emit(CodeValidationFailure(failure)),
      (_) => emit(CodeValidationSuccess()),
    );
  }
}
