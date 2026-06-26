class VerifyOtpResult {
  final String customerId;
  final Map<String, bool> verificationChannels;

  const VerifyOtpResult({
    required this.customerId,
    required this.verificationChannels,
  });
}
