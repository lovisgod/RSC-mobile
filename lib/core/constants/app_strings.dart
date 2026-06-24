abstract final class AppStrings {
  // ─── Bottom nav tab labels ────────────────────────────────────────────────
  static const String tabHome = 'Home';
  static const String tabSearch = 'Search';
  static const String tabCart = 'Cart';
  static const String tabTrack = 'Track';
  static const String tabProfile = 'Profile';

  // ─── Auth — branding ─────────────────────────────────────────────────────
  static const String appBrandName = 'RSC';
  static const String appBrandSuffix = 'Food';
  static const String loginSubtitle = 'Welcome back! Please log in to order delicious meals.';
  static const String registerSubtitle = 'Create an account to discover restaurants around you.';

  // ─── Auth — field labels (uppercase, shown above inputs) ─────────────────
  static const String labelEmailOrPhone = 'EMAIL OR PHONE';
  static const String labelPassword = 'PASSWORD';
  static const String labelFullName = 'FULL NAME';
  static const String labelEmail = 'EMAIL';
  static const String labelPhone = 'PHONE NUMBER';
  static const String labelConfirmPassword = 'CONFIRM PASSWORD';

  // ─── Auth — field hints ───────────────────────────────────────────────────
  static const String hintEmailOrPhone = 'Enter email or phone number';
  static const String hintPassword = 'Enter your password';
  static const String hintFullName = 'Enter your full name';
  static const String hintEmail = 'Enter your email address';
  static const String hintPhone = 'Enter your phone number';
  static const String hintConfirmPassword = 'Confirm your password';

  // ─── Auth — buttons & links ───────────────────────────────────────────────
  static const String btnLogin = 'Log In';
  static const String btnRegister = 'Register';
  static const String loginFooterText = "Don't have an account?";
  static const String registerFooterText = 'Already have an account?';

  // ─── Auth — messages ─────────────────────────────────────────────────────
  static const String registerSuccessMsg =
      'Account created successfully! Please log in.';

  // ─── OTP verification ────────────────────────────────────────────────────
  static const String otpTitle = 'Enter Verification Code';
  static const String otpSubtitleStart = 'We sent a 4-digit code to ';
  static const String otpSubtitleEnd =
      '. Enter it below to complete verification.';
  static const String btnVerifyAndProceed = 'Verify & Proceed';

  // ─── Snackbar messages ────────────────────────────────────────────────────
  static const String snackLoggingIn = 'Logging in...';
  static const String snackCreatingAccount = 'Creating your account...';
  static const String snackSendingOtp = 'Sending OTP...';
  static const String snackOtpResent = 'OTP resent successfully!';

  // ─── Validation errors ────────────────────────────────────────────────────
  static const String errorFieldRequired = 'This field is required';
  static const String errorPasswordMin =
      'Password must be at least 6 characters';
  static const String errorPasswordsMismatch = 'Passwords do not match';
  static const String errorInvalidEmail = 'Enter a valid email address';
  static const String errorPhoneTooShort =
      'Phone number must be at least 11 digits';
  static const String errorPhoneInvalidChars =
      'Phone number contains invalid characters';
}
