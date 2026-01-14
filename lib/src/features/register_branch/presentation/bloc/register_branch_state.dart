import 'package:motogo_frontend/src/core/errors/error_model.dart';

/// States for the RegisterBranchBloc.
abstract class RegisterBranchState {}

/// Initial state before any action.
class RegisterBranchInitial extends RegisterBranchState {}

/// State while registration is in progress.
class RegisterBranchLoading extends RegisterBranchState {}

/// State when registration succeeds.
class RegisterBranchSuccess extends RegisterBranchState {
  final String message;
  final String? branchId;

  RegisterBranchSuccess({required this.message, this.branchId});
}

/// State when registration fails.
class RegisterBranchFailure extends RegisterBranchState {
  final ErrorModel error;

  RegisterBranchFailure({required this.error});
}
