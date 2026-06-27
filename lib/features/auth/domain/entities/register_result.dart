class RegisterResult {
  final String customerId;
  final int otpExpiresInSeconds;
  final Map<String, bool> verificationChannels;

  const RegisterResult({
    required this.customerId,
    required this.otpExpiresInSeconds,
    required this.verificationChannels,
  });
}
