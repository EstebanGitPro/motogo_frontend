part of 'code_validation_bloc.dart';

abstract class CodeValidationEvent extends Equatable {
  const CodeValidationEvent();
}

class CodeValidationSubmitted extends CodeValidationEvent {
  final String code;

  const CodeValidationSubmitted({required this.code});

  @override
  List<Object> get props => [code];
}
