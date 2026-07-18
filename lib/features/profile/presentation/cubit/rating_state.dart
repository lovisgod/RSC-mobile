class RatingState {
  final bool isSubmitting;
  final bool isSubmitted;
  final String? error;

  /// Menu item ids already rated this session — a second rating for any of
  /// them is silently dropped. Lives in a singleton cubit so it survives
  /// screen changes.
  final List<String> ratedItemIds;

  const RatingState({
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.error,
    this.ratedItemIds = const [],
  });

  RatingState copyWith({
    bool? isSubmitting,
    bool? isSubmitted,
    String? error,
    bool clearError = false,
    List<String>? ratedItemIds,
  }) {
    return RatingState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      error: clearError ? null : (error ?? this.error),
      ratedItemIds: ratedItemIds ?? this.ratedItemIds,
    );
  }
}
