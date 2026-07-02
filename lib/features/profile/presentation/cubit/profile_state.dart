import '../../domain/entities/profile.dart';

class ProfileState {
  final bool isLoggedIn;
  final Profile? userProfile;
  final bool isLoading;
  final bool isUploadingAvatar;
  final bool requiresOtpVerification;
  final int otpExpiresInSeconds;
  final String? error;

  const ProfileState({
    required this.isLoggedIn,
    this.userProfile,
    this.isLoading = false,
    this.isUploadingAvatar = false,
    this.requiresOtpVerification = false,
    this.otpExpiresInSeconds = 0,
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
      error: error,
    );
  }

  factory ProfileState.loaded(Profile profile) =>
      ProfileState(isLoggedIn: true, userProfile: profile);
}
