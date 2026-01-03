part of 'edit_profile_bloc.dart';

enum EditProfileStatus { initial, loading, success, failure }

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.user,
    this.error,
    this.successMessage,
    this.isFromCache = false,
  });

  final EditProfileStatus status;
  final UserEntity? user;
  final String? error;
  final String? successMessage;
  final bool isFromCache;

  EditProfileState copyWith({
    EditProfileStatus? status,
    UserEntity? user,
    String? error,
    String? successMessage,
    bool? isFromCache,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      successMessage: successMessage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, user, error, successMessage, isFromCache];
}
