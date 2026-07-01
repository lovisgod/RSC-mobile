import '../../../../core/mock/mock_user.dart';
import '../../domain/entities/profile.dart';

class ProfileState {
  final bool isLoggedIn;
  final Profile? userProfile;
  final bool isLoading;
  final bool isUploadingAvatar;
  final String? error;
  final String defaultAddress;

  const ProfileState({
    required this.isLoggedIn,
    this.userProfile,
    this.isLoading = false,
    this.isUploadingAvatar = false,
    this.error,
    this.defaultAddress = 'No address set',
  });

  factory ProfileState.guest() => const ProfileState(isLoggedIn: false);

  ProfileState copyWith({
    bool? isLoggedIn,
    Profile? userProfile,
    bool? isLoading,
    bool? isUploadingAvatar,
    String? error,
    String? defaultAddress,
  }) {
    return ProfileState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
      error: error,
      defaultAddress: defaultAddress ?? this.defaultAddress,
    );
  }

  factory ProfileState.loaded(Profile profile) => ProfileState(
    isLoggedIn: true,
    userProfile: profile,
    defaultAddress: MockUser.defaultAddress,
  );
}
