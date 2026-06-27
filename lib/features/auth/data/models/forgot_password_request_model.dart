class ForgotPasswordRequestModel {
  final String identifier;

  const ForgotPasswordRequestModel({required this.identifier});

  Map<String, dynamic> toJson() => {'identifier': identifier};
}
