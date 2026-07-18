import '../../data/models/verify_payment_response_model.dart';
import '../repositories/payment_repository.dart';

class VerifyPaymentUseCase {
  const VerifyPaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<VerifyPaymentResponseModel> call(String reference) =>
      _repository.verifyPayment(reference);
}
