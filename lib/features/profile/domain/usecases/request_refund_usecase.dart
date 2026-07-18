import '../repositories/refund_repository.dart';

class RequestRefundUsecase {
  const RequestRefundUsecase(this._repository);

  final RefundRepository _repository;

  Future<void> call(String reference, int amountMinor, String reason) =>
      _repository.requestRefund(reference, amountMinor, reason);
}
