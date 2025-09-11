part of 'code_validation_bloc.dart';

abstract class CodeValidationState extends Equatable {
  const CodeValidationState();
}

class CodeValidationInitial extends CodeValidationState {
  const CodeValidationInitial();

  @override
  List<Object> get props => [];
}

class CodeValidationLoading extends CodeValidationState {
  const CodeValidationLoading();

  @override
  List<Object> get props => [];
}

class CodeValidationSuccess extends CodeValidationState {
  const CodeValidationSuccess();

  @override
  List<Object> get props => [];
}

class CodeValidationFailure extends CodeValidationState {
  final ErrorModel error;

  const CodeValidationFailure(this.error);

  @override
  List<Object> get props => [error];
}

class CodeValidationResending extends CodeValidationState {
  const CodeValidationResending();

  @override
  List<Object> get props => [];
}

class CodeValidationResendSuccess extends CodeValidationState {
  const CodeValidationResendSuccess();

  @override
  List<Object> get props => [];
}
