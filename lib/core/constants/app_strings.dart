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

  // ─── OTP verification screen ──────────────────────────────────────────────
  static const String otpTitle = 'Verify Your Account';
  static const String otpSubtitle = 'Enter the 6-digit code sent to your phone and email';
  static const String otpChannelPhone = 'Phone';
  static const String otpChannelEmail = 'Email';
  static const String otpCodeExpiresIn = 'Code expires in ';
  static const String otpCodeExpired = 'Code expired';
  static const String btnVerify = 'Verify';
  static const String btnResendCode = 'Resend Code';
  static const String otpVerifySuccessMsg = 'Account verified! Please log in.';
  static const String snackVerifyingOtp = 'Verifying code...';
  static const String snackResendingOtp = 'Resending code...';
  static const String snackOtpResent = 'A new code has been sent.';
  static const String newCodeSentTo = 'New code sent to your ';

  // ─── Snackbar messages ────────────────────────────────────────────────────
  static const String snackLoggingIn = 'Logging in...';
  static const String snackCreatingAccount = 'Creating your account...';
  static const String snackSendingOtp = 'Sending verification code...';

  // ─── Home screen ──────────────────────────────────────────────────────────
  static const String deliveringTo = 'DELIVERING TO';
  static const String deliveryAddress = 'Lagos, Nigeria';
  static const String rscFoodKitchens = 'RSC Food Kitchens';
  static const String freeDeliveryToday = 'Free Delivery Today!';
  static const String freeDeliverySubtitle = 'On all orders above ₦2,000';
  static const String orderNow = 'Order Now';
  static const String popular = 'Popular';
  static const String closed = 'Closed';
  static const String noMenuItems = 'No items in this category';
  static const String errorLoadingOutlets = 'Failed to load restaurants';
  static const String retry = 'Retry';

  // ─── Cart & item detail ───────────────────────────────────────────────────
  static const String unifiedCart = 'Unified Cart';
  static const String addToUnifiedCart = 'Add to Unified Cart';
  static const String proceedToCheckout = 'Proceed to Checkout →';
  static const String itemAddedToCart = 'added to cart';
  static const String yourCartIsEmpty = 'Your cart is empty';
  static const String cartEmptySubtitle = 'Discover menus from popular outlets and customize your order.';
  static const String browseOutlets = 'Browse Outlets';
  static const String browseRestaurants = 'Browse Restaurants';
  static const String subtotal = 'Subtotal';
  static const String vatLabel = 'VAT (7.5%)';
  static const String estimatedTotal = 'Estimated Total';
  static const String required = 'Required';
  static const String optional = 'Optional';
  static const String addExtras = 'Add Extras';
  static const String items = 'items';

  // ─── Order History ────────────────────────────────────────────────────────
  static const String seeAllOrders = 'See All →';
  static const String orderDetails = 'Order Details';
  static const String orderIdLabel = 'ORDER ID';
  static const String deliveredAndComplete = 'Delivered & Complete ✅';
  static const String reorderEntireOrder = 'Re-order this entire order 🔄';
  static const String itemsOrdered = 'ITEMS ORDERED';
  static const String noOrdersYet = 'No orders yet';
  static const String startOrdering = 'Start ordering from RSC Food Kitchens';
  static const String reorder = 'Re-order';
  static const String deliveryModeLabel = 'DELIVERY';
  static const String takeoutModeLabel = 'TAKEOUT';
  static const String moreItemSuffix = 'more item';
  static const String moreItemsSuffix = 'more items';
  static const String subOrderSuffix = ' Sub-Order';

  // ─── Track ────────────────────────────────────────────────────────────────
  static const String orderProgress = 'Order Progress';
  static const String noActiveOrders = 'No active orders to track';
  static const String browseKitchensToOrder = 'Browse kitchens to place a food order.';
  static const String noOrderId = '#NO-ORDER';
  static const String trackingComingSoon = 'Full order tracking coming soon';
  static const String estimatedDeliveryTime = 'ESTIMATED DELIVERY TIME';
  static const String etaProcessing = 'Processing...';
  static const String etaDelivered = 'Delivered! 🎉';
  static const String kitchenIsPreparingMeals = 'Kitchen is preparing your meals';
  static const String kitchenBreakdowns = 'KITCHEN BREAKDOWNS';
  static const String deliveryHandoffCode = 'DELIVERY HANDOFF CODE';
  static const String shareDeliveryCode =
      'Share this code with the rider upon receiving the delivery.';
  static const String riderActiveStatusPrefix = 'Active Status: ';
  static const String riderStatusAssigned = 'ASSIGNED';
  static const String riderStatusPickedUp = 'PICKED UP';
  static const String riderStatusDelivered = 'DELIVERED';

  // ─── Search ───────────────────────────────────────────────────────────────
  static const String searchAcrossAllOutlets = 'Search across all outlets...';
  static const String searchYourFavouriteMeal = 'Search for your favourite meal';
  static const String noResultsFor = 'No results for';
  static const String trySearchingBy = 'Try searching by meal name, cuisine, or restaurant';
  static const String viewOptions = 'View options';
  static const String updateCart = 'Update Cart';
  static const String inCart = 'In cart';
  static const String updatedInCart = 'updated in cart';

  // ─── Profile ──────────────────────────────────────────────────────────────
  static const String editProfile = 'Edit Profile';
  static const String defaultDeliveryAddress = 'DEFAULT DELIVERY ADDRESS';
  static const String setDefault = 'Set Default';
  static const String orderHistory = 'Order History';
  static const String noOrderHistory = 'You haven\'t placed any orders yet.';
  static const String loginToViewOrders = 'Log in to view your orders';
  static const String logOut = 'Log Out';
  static const String logOutConfirmTitle = 'Log Out';
  static const String logOutConfirmMessage = 'Are you sure you want to log out?';
  static const String cancel = 'Cancel';
  static const String clearAll = 'Clear All';
  static const String clearCart = 'Clear Cart';
  static const String clearCartMessage =
      'Are you sure you want to remove all items from your cart?';
  static const String cartCleared = 'Cart cleared';
  static const String comingSoon = 'Coming soon';

  // ─── Order status labels ──────────────────────────────────────────────────
  static const String statusDelivered = 'Delivered';
  static const String statusCancelled = 'Cancelled';
  static const String statusPending = 'Pending';
  static const String statusConfirmed = 'Confirmed';
  static const String statusPreparing = 'Preparing';
  static const String statusDispatched = 'Dispatched';
  static const String statusReady = 'Ready';

  // ─── Checkout ─────────────────────────────────────────────────────────────
  static const String checkout = 'Checkout';
  static const String deliveryTab = '🚴 Delivery';
  static const String takeoutTab = '🛍️ Takeout';
  static const String sectionDeliveryAddress = 'DELIVERY ADDRESS';
  static const String typeDeliveryAddressHint =
      'Type delivery address (e.g. Victoria Island)';
  static const String useDefaultAddress = '📍 Use Default Address';
  static const String orderForSomeoneElse =
      'Order on behalf of someone inside geofence';
  static const String recipientInGeofenceAddress =
      'RECIPIENT IN-GEOFENCE ADDRESS';
  static const String recipientNameLabel = 'RECIPIENT NAME';
  static const String sectionPreparationInstructions =
      'PREPARATION INSTRUCTIONS';
  static const String preparationInstructionsHint =
      'e.g., Make the Cactus Suya extra spicy, no onions...';
  static const String priceBreakdown = 'Price Breakdown';
  static const String deliveryFeeLabel = 'Delivery Fee';
  static const String grandTotal = 'Grand Total';
  static const String proceedToPayment = 'Proceed to Payment 🚀';
  static const String paymentComingSoon = 'Payment coming soon 🚀';
  static const String pleaseLoginToOrder = 'Please log in to place an order';
  static const String pleaseEnterDeliveryAddress =
      'Please enter a delivery address';

  // ─── Payment (Moment) ─────────────────────────────────────────────────────
  static const String tabCard = '💳 Card';
  static const String tabTransfer = '🏦 Transfer';
  static const String tabUssd = '📱 USSD';
  static const String cardNumberHint = '5399 4120 4930 4521';
  static const String expiry = 'MM/YY';
  static const String cvv = 'CVV';
  static const String transferInstructions =
      'Transfer exactly the amount above. Click verification below.';
  static const String selectBank = 'Select your bank';
  static const String ussdDialPrefix = 'Dial ';
  static const String ussdDialSuffix =
      ' on your phone to complete payment';
  static const String paySecurelyWithMoment = 'Pay Securely with Moment';
  static const String iSentTheMoney = 'I\'ve Sent the Money';
  static const String iDialledTheCode = 'I\'ve Dialled the Code';
  static const String processing = 'Processing...';
  static const String cancelTransaction = 'Cancel Transaction';
  static const String orderPlacedSuccessfully = '🎉 Order placed successfully!';
  static const String paymentFailed = 'Payment failed. Please try again.';

  // ─── Change password (logged-in flow) ────────────────────────────────────
  static const String changePassword = 'Change Password';
  static const String security = 'Security';
  static const String labelCurrentPassword = 'CURRENT PASSWORD';
  static const String labelConfirmNewPassword = 'CONFIRM NEW PASSWORD';
  static const String hintCurrentPassword = 'Enter current password';
  static const String hintNewPasswordMin =
      'Enter new password (min. 6 characters)';
  static const String updatePassword = 'Update Password';
  static const String passwordUpdatedSuccessfully =
      'Password updated successfully';
  static const String newPasswordSameAsCurrent =
      'New password must be different from current password';
  static const String sessionExpiredLogin =
      'Session expired. Please log in again.';

  // ─── Forgot / Reset password ──────────────────────────────────────────────
  static const String forgotPasswordTitle = 'Forgot Password';
  static const String forgotPasswordLink = 'Forgot Password?';
  static const String forgotPasswordSubtitle =
      'Enter your email or phone number and we\'ll send you a reset code.';
  static const String sendResetCode = 'Send Reset Code';
  static const String enterResetCode = 'Enter Reset Code';
  static const String resetOtpSubtitle =
      'A 6-digit reset code has been sent to your phone and email.';
  static const String setNewPassword = 'Set New Password';
  static const String newPasswordSubtitle =
      'Your new password must be at least 6 characters.';
  static const String labelNewPassword = 'NEW PASSWORD';
  static const String hintNewPassword = 'Enter new password';
  static const String hintConfirmNewPassword = 'Confirm new password';
  static const String resetPassword = 'Reset Password';
  static const String passwordResetSuccess =
      'Password reset successfully! Please log in.';
  static const String rememberYourPassword = 'Remember your password?';
  static const String requestNewCode = 'Request a new code';
  static const String invalidOrExpiredCode =
      'Invalid or expired code. Please request a new one.';

  // ─── Validation errors ────────────────────────────────────────────────────
  static const String errorFieldRequired = 'This field is required';
  static const String errorPasswordMin = 'Password must be at least 6 characters';
  static const String errorPasswordsMismatch = 'Passwords do not match';
  static const String errorInvalidEmail = 'Enter a valid email address';
  static const String errorPhoneTooShort = 'Phone number must be at least 11 digits';
  static const String errorPhoneInvalidChars = 'Phone number contains invalid characters';
  static const String errorInactiveAccount = 'Please verify your account first';
}
