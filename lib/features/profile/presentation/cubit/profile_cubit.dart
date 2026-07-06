import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/verify_profile_change_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final LocalStorage _localStorage;
  final GetProfileUseCase _getProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final VerifyProfileChangeUseCase _verifyProfileChangeUseCase;

  ProfileCubit(
    this._localStorage,
    this._getProfileUseCase,
    this._uploadAvatarUseCase,
    this._updateProfileUseCase,
    this._verifyProfileChangeUseCase,
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
    final previousAvatarUrl = state.userProfile?.avatarUrl;
    emit(state.copyWith(isUploadingAvatar: true, error: null));
    try {
      final profile = await _uploadAvatarUseCase(imageFile);

      // The backend overwrites the same Cloudinary path on every upload, so
      // the URL string doesn't change between uploads. CachedNetworkImage
      // keys its cache by that URL, so without evicting it here the widget
      // would keep showing the old image bytes forever.
      if (previousAvatarUrl != null) {
        await CachedNetworkImage.evictFromCache(previousAvatarUrl);
      }

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

  Future<void> updateProfile(String name, String phone, String email) async {
    emit(
      state.copyWith(
        isLoading: true,
        error: null,
        requiresOtpVerification: false,
      ),
    );
    try {
      final response = await _updateProfileUseCase(name, phone, email);
      final otpExpiresInSeconds = response.otpExpiresInSeconds;
      if (otpExpiresInSeconds != null) {
        emit(
          state.copyWith(
            isLoading: false,
            requiresOtpVerification: true,
            otpExpiresInSeconds: otpExpiresInSeconds,
          ),
        );
      } else {
        await loadProfile();
      }
    } on AuthException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to update profile. Please try again.',
        ),
      );
    }
  }

  Future<void> verifyProfileChange(String code) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final profile = await _verifyProfileChangeUseCase(code);
      emit(
        state.copyWith(
          userProfile: profile,
          requiresOtpVerification: false,
          isLoading: false,
        ),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to verify code. Please try again.',
        ),
      );
    }
  }
}
