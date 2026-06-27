class ProfileState {
  final bool isLoggedIn;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String userInitials;
  final String defaultAddress;

  const ProfileState({
    required this.isLoggedIn,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.userInitials,
    required this.defaultAddress,
  });

  factory ProfileState.guest() => const ProfileState(
        isLoggedIn: false,
        userName: 'Guest User',
        userEmail: 'guest@rscfood.com',
        userPhone: 'N/A',
        userInitials: 'GU',
        defaultAddress: 'No address set',
      );
}
