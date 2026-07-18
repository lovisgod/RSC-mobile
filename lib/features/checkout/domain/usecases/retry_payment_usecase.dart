import '../../data/models/retry_payment_response_model.dart';
import '../repositories/payment_repository.dart';

class RetryPaymentUseCase {
  const RetryPaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<RetryPaymentResponseModel> call(String orderId) =>
      _repository.retryPayment(orderId);
}
