abstract final class AppConstants {
  static const String appName = 'RSC';

  static const int otpLength = 6;
  static const int otpResendSeconds = 60;

  static const int cartHiveTypeId = 0;
  static const int selectedModifierHiveTypeId = 1;

  static const double vatRate = 0.075;

  /// Deep link Moment redirects to after a checkout (initiate or retry)
  /// completes.
  static const String paymentReturnUrl = 'rsc://payment/return';
}
