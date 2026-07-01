import '../../data/models/initiate_payment_request_model.dart';
import '../../data/models/initiate_payment_response_model.dart';
import '../repositories/payment_repository.dart';

class InitiatePaymentUseCase {
  const InitiatePaymentUseCase(this._repository);

  final PaymentRepository _repository;

  Future<InitiatePaymentResponseModel> call(
    InitiatePaymentRequestModel request,
  ) =>
      _repository.initiatePayment(request);
}
