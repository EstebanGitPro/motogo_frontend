part of 'edit_profile_bloc.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

class EditProfileLoaded extends EditProfileEvent {
  const EditProfileLoaded({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class EditProfileSaved extends EditProfileEvent {
  const EditProfileSaved(this.updated);

  final UserEntity updated;

  @override
  List<Object?> get props => [updated];
}

class EditProfileCacheCleared extends EditProfileEvent {
  const EditProfileCacheCleared();
}
