abstract class RefundRepository {
  Future<void> requestRefund(String reference, int amountMinor, String reason);
}
