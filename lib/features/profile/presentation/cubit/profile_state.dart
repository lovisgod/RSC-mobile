import '../../domain/entities/profile.dart';

class ProfileState {
  final bool isLoggedIn;
  final Profile? userProfile;
  final bool isLoading;
  final bool isUploadingAvatar;
  final bool requiresOtpVerification;
  final int otpExpiresInSeconds;
  final bool isDeactivating;

  /// The deactivate call succeeded — the screen reacts by running the full
  /// logout flow.
  final bool deactivated;
  final bool isDeleting;

  /// The permanent delete call succeeded and all local session data has been
  /// cleared — the screen reacts by resetting auth and navigating home.
  final bool deleted;
  final String? error;

  const ProfileState({
    required this.isLoggedIn,
    this.userProfile,
    this.isLoading = false,
    this.isUploadingAvatar = false,
    this.requiresOtpVerification = false,
    this.otpExpiresInSeconds = 0,
    this.isDeactivating = false,
    this.deactivated = false,
    this.isDeleting = false,
    this.deleted = false,
    this.error,
  });

  factory ProfileState.guest() => const ProfileState(isLoggedIn: false);

  ProfileState copyWith({
    bool? isLoggedIn,
    Profile? userProfile,
    bool? isLoading,
    bool? isUploadingAvatar,
    bool? requiresOtpVerification,
    int? otpExpiresInSeconds,
    bool? isDeactivating,
    bool? deactivated,
    bool? isDeleting,
    bool? deleted,
    String? error,
  }) {
    return ProfileState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      requiresOtpVerification:
          requiresOtpVerification ?? this.requiresOtpVerification,
      otpExpiresInSeconds: otpExpiresInSeconds ?? this.otpExpiresInSeconds,
      isDeactivating: isDeactivating ?? this.isDeactivating,
      deactivated: deactivated ?? this.deactivated,
      isDeleting: isDeleting ?? this.isDeleting,
      deleted: deleted ?? this.deleted,
      error: error,
    );
  }

  factory ProfileState.loaded(Profile profile) =>
      ProfileState(isLoggedIn: true, userProfile: profile);
}
