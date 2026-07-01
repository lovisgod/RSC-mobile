import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final LocalStorage _localStorage;
  final GetProfileUseCase _getProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;

  ProfileCubit(
    this._localStorage,
    this._getProfileUseCase,
    this._uploadAvatarUseCase,
  ) : super(ProfileState.guest());

  Future<void> loadProfile() async {
    final user = await _localStorage.getUser();
    if (user == null) {
      emit(ProfileState.guest());
      return;
    }

    emit(state.copyWith(isLoggedIn: true, isLoading: true, error: null));
    try {
      final profile = await _getProfileUseCase();
      emit(ProfileState.loaded(profile));
    } on AuthException catch (e) {
      if (e.message == AppStrings.sessionExpiredLogin) {
        await _localStorage.clearAll();
        emit(ProfileState.guest());
      } else {
        emit(state.copyWith(isLoading: false, error: e.message));
      }
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load profile. Please try again.',
        ),
      );
    }
  }

  Future<void> uploadAvatar(File imageFile) async {
    emit(state.copyWith(isUploadingAvatar: true, error: null));
    try {
      final profile = await _uploadAvatarUseCase(imageFile);
      emit(
        state.copyWith(
          userProfile: profile,
          isUploadingAvatar: false,
          error: null,
        ),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(isUploadingAvatar: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isUploadingAvatar: false,
          error: 'Failed to upload photo. Please try again.',
        ),
      );
    }
  }
}
