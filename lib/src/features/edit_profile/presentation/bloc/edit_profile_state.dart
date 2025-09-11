part of 'edit_profile_bloc.dart';

enum EditProfileStatus { initial, loading, success, failure }

class EditProfileState extends Equatable {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.person,
    this.error,
    this.isFromCache = false,
  });

  final EditProfileStatus status;
  final PersonEntity? person;
  final String? error;
  final bool isFromCache;

  EditProfileState copyWith({
    EditProfileStatus? status,
    PersonEntity? person,
    String? error,
    bool? isFromCache,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      person: person ?? this.person,
      error: error, 
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, person, error, isFromCache];
}