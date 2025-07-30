import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'dart:convert';

import 'package:motogo_frontend/src/features/edit_profile/domain/entities/edit_profile_entity.dart';
import 'package:motogo_frontend/src/features/edit_profile/data/models/edit_profile_model.dart';
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

  static const String _cachedPersonKey = 'cached_person_data';
  static const String _lastUpdateKey = 'last_person_update';
  static const String _userIdKey = 'user_id';

  Future<void> _onLoaded(
    EditProfileLoaded event,
    Emitter<EditProfileState> emit,
    GetPersonUsecase getPersonUsecase,
  ) async {
    emit(state.copyWith(status: EditProfileStatus.loading));

    try {
      final cachedPerson = await _getCachedPerson();
      if (cachedPerson != null && !event.forceRefresh) {
        emit(
          state.copyWith(
            person: cachedPerson,
            status: EditProfileStatus.success,
            isFromCache: true,
          ),
        );
      }

      final result = await getPersonUsecase();
      result.fold(
        (failure) {
          if (cachedPerson == null) {
            emit(
              state.copyWith(
                status: EditProfileStatus.failure,
                error: failure.message,
              ),
            );
          }
        },
        (person) {
          _cachePerson(person);
          emit(
            state.copyWith(
              person: person,
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
        (_) {
          _cachePerson(event.updated);
          emit(
            state.copyWith(
              person: event.updated,
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

  Future<void> _onCacheCleared(
    EditProfileCacheCleared event,
    Emitter<EditProfileState> emit,
  ) async {
    await _clearCache();
    emit(state.copyWith(isFromCache: false));
  }

  Future<PersonEntity?> _getCachedPerson() async {
    try {
      final secureStorage = FlutterSecureStorage();
      final cachedData = await secureStorage.read(key: _cachedPersonKey);

      if (cachedData != null) {
        final Map<String, dynamic> json = jsonDecode(cachedData);

        final lastUpdateString = await secureStorage.read(key: _lastUpdateKey);
        if (lastUpdateString != null) {
          final lastUpdate = int.tryParse(lastUpdateString) ?? 0;
          final now = DateTime.now().millisecondsSinceEpoch;
          const cacheValidityDuration = 60 * 60 * 1000;

          if (now - lastUpdate < cacheValidityDuration) {
            final personModel = PersonModel.fromMap(json);
            return PersonEntity(
              id: personModel.id,
              role: personModel.role,
              identityNumber: personModel.identityNumber,
              firstName: personModel.firstName,
              lastName: personModel.lastName,
              secondLastName: personModel.secondLastName,
              email: personModel.email,
              phoneNumber: personModel.phoneNumber,
              emailVerified: personModel.emailVerified,
              phoneNumberVerified: personModel.phoneNumberVerified,
            );
          }
        }
      }
    } catch (e) {
      await _clearCache();
      debugPrint('Error reading cache: $e');
    }
    return null;
  }

  Future<void> _cachePerson(PersonEntity person) async {
    try {
      final secureStorage = FlutterSecureStorage();

      final personModel = PersonModel(
        id: person.id,
        role: person.role,
        identityNumber: person.identityNumber,
        firstName: person.firstName,
        lastName: person.lastName,
        secondLastName: person.secondLastName,
        email: person.email,
        phoneNumber: person.phoneNumber,
        emailVerified: person.emailVerified,
        phoneNumberVerified: person.phoneNumberVerified,
      );

      final jsonString = jsonEncode(personModel.toMap());
      await secureStorage.write(key: _cachedPersonKey, value: jsonString);
      await secureStorage.write(
        key: _lastUpdateKey,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      debugPrint('Error saving secure cache: $e');
    }
  }

  Future<void> _clearCache() async {
    try {
      final secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: _cachedPersonKey);
      await secureStorage.delete(key: _lastUpdateKey);
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      final secureStorage = FlutterSecureStorage();
      return await secureStorage.read(key: _userIdKey);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      return null;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final secureStorage = FlutterSecureStorage();
      return await secureStorage.read(key: 'auth_token');
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }
}
