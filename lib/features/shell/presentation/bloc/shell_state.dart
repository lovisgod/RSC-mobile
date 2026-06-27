class ShellState {
  final int activeTabIndex;
  final bool isAuthenticated;
  final String? userId;

  const ShellState({
    required this.activeTabIndex,
    required this.isAuthenticated,
    this.userId,
  });

  factory ShellState.initial() => const ShellState(
        activeTabIndex: 0,
        isAuthenticated: false,
      );

  // Populated when profile is fetched — null until then
  String? get userInitials => null;

  ShellState copyWith({
    int? activeTabIndex,
    bool? isAuthenticated,
    String? userId,
    bool clearUser = false,
  }) {
    return ShellState(
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: clearUser ? null : (userId ?? this.userId),
    );
  }
}
