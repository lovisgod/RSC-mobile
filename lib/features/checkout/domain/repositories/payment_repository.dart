import '../../data/models/initiate_payment_request_model.dart';
import '../../data/models/initiate_payment_response_model.dart';

abstract class PaymentRepository {
  /// Initiates a Paystack payment session. Auth is sent automatically via the
  /// persisted cookie session. Throws [AuthException] on 401 (session expired)
  /// and a generic [Exception] with the server's first error otherwise.
  Future<InitiatePaymentResponseModel> initiatePayment(
    InitiatePaymentRequestModel request,
  );
}
