import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/usecases/deactivate_account_usecase.dart';
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
  final DeactivateAccountUsecase _deactivateAccountUsecase;

  ProfileCubit(
    this._localStorage,
    this._getProfileUseCase,
    this._uploadAvatarUseCase,
    this._updateProfileUseCase,
    this._verifyProfileChangeUseCase,
    this._deactivateAccountUsecase,
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
      // Session-expiry storage clearing/guest reset is handled globally by
      // SessionInterceptor + AuthBloc now; any other AuthException just
      // surfaces as a normal error.
      emit(state.copyWith(isLoading: false, error: e.message));
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

  /// On success only flips [ProfileState.deactivated] — clearing cookies,
  /// storage, cart and the socket is the screen's job via AuthBloc's
  /// SessionExpired/LogoutSuccess pipeline, which already owns that cleanup.
  Future<void> deactivateAccount() async {
    emit(state.copyWith(isDeactivating: true, error: null));
    try {
      await _deactivateAccountUsecase();
      emit(state.copyWith(isDeactivating: false, deactivated: true));
    } on AuthException catch (e) {
      emit(state.copyWith(isDeactivating: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isDeactivating: false,
          error: 'Failed to deactivate account. Please try again.',
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
