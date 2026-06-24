import '../../../auth/domain/entities/user.dart';

class ShellState {
  final int activeTabIndex;
  final bool isAuthenticated;
  final User? currentUser;

  const ShellState({
    required this.activeTabIndex,
    required this.isAuthenticated,
    this.currentUser,
  });

  factory ShellState.initial() => const ShellState(
        activeTabIndex: 0,
        isAuthenticated: false,
      );

  String? get userInitials => currentUser?.initials;

  ShellState copyWith({
    int? activeTabIndex,
    bool? isAuthenticated,
    User? currentUser,
    bool clearUser = false,
  }) {
    return ShellState(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
    );
  }
}
