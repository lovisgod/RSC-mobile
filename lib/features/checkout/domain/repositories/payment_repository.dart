import '../../data/models/initiate_payment_request_model.dart';
import '../../data/models/initiate_payment_response_model.dart';
import '../../data/models/retry_payment_response_model.dart';
import '../../data/models/verify_payment_response_model.dart';
import '../entities/platform_charges_entity.dart';

abstract class PaymentRepository {
  /// Initiates a Paystack payment session. Auth is sent automatically via the
  /// persisted cookie session. Throws [AuthException] on 401 (session expired)
  /// and a generic [Exception] with the server's first error otherwise.
  Future<InitiatePaymentResponseModel> initiatePayment(
    InitiatePaymentRequestModel request,
  );

  /// Retrieves platform charges like commission BPS, delivery fees, etc.
  Future<PlatformChargesEntity> getPlatformCharges();

  /// Confirms the outcome of a Moment payment handoff by reference.
  Future<VerifyPaymentResponseModel> verifyPayment(String reference);

  /// Re-initiates payment for an existing PENDING_PAYMENT order and returns
  /// a fresh Moment checkout handoff.
  Future<RetryPaymentResponseModel> retryPayment(String orderId);
}
