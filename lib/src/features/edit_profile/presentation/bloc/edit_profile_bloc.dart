import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/user_session_manager.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/get_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/update_person_usecase.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState()) {
    final GetPersonUsecase getPersonUsecase =
        InjectorApp.resolve<GetPersonUsecase>();
    final UpdatePersonUsecase updatePersonUsecase =
        InjectorApp.resolve<UpdatePersonUsecase>();

    on<EditProfileLoaded>(
      (event, emit) => _onLoaded(event, emit, getPersonUsecase),
    );
    on<EditProfileSaved>(
      (event, emit) => _onSaved(event, emit, updatePersonUsecase),
    );
    on<EditProfileCacheCleared>(_onCacheCleared);
  }

  Future<void> _onLoaded(
    EditProfileLoaded event,
    Emitter<EditProfileState> emit,
    GetPersonUsecase getPersonUsecase,
  ) async {
    emit(state.copyWith(status: EditProfileStatus.loading));

    try {
      // Primero intentar obtener desde el cache en memoria
      final cachedUser = await _getCachedUser();
      if (cachedUser != null && !event.forceRefresh) {
        emit(
          state.copyWith(
            user: cachedUser,
            status: EditProfileStatus.success,
            isFromCache: true,
          ),
        );
      }

      // Obtener datos frescos del servidor
      final result = await getPersonUsecase();
      result.fold(
        (failure) {
          if (cachedUser == null) {
            emit(
              state.copyWith(
                status: EditProfileStatus.failure,
                error: failure.message,
              ),
            );
          }
        },
        (user) {
          emit(
            state.copyWith(
              user: user,
              status: EditProfileStatus.success,
              isFromCache: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          error: 'Error inesperado: $e',
        ),
      );
    }
  }

  Future<void> _onSaved(
    EditProfileSaved event,
    Emitter<EditProfileState> emit,
    UpdatePersonUsecase updatePersonUsecase,
  ) async {
    emit(state.copyWith(status: EditProfileStatus.loading));

    try {
      final result = await updatePersonUsecase(event.updated);
      result.fold(
        (failure) => emit(
          state.copyWith(
            status: EditProfileStatus.failure,
            error: failure.message,
          ),
        ),
        (successMessage) {
          // El UserSessionManager ya tiene los datos actualizados
          emit(
            state.copyWith(
              user: event.updated,
              status: EditProfileStatus.success,
              successMessage: successMessage,
              isFromCache: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          error: 'Error inesperado: $e',
        ),
      );
    }
  }

  Future<void> _onCacheCleared(
    EditProfileCacheCleared event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(isFromCache: false));
  }

  /// Obtiene el usuario desde el cache del UserSessionManager
  Future<UserEntity?> _getCachedUser() async {
    try {
      return await UserSessionManager.instance.getCurrentUser();
    } catch (_) {
      return null;
    }
  }
}
