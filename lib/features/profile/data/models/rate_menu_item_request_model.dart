class RateMenuItemRequestModel {
  final int rating;
  final String? comment;

  const RateMenuItemRequestModel({required this.rating, this.comment});

  Map<String, dynamic> toJson() => {
    'rating': rating,
    if (comment != null) 'comment': comment,
  };
}
