import 'dart:math';

abstract final class OrderIdGenerator {
  static final _random = Random();

  static String generateOrderId() {
    final number = _random.nextInt(90000000) + 10000000;
    return 'RSC-$number';
  }

  static String generateDeliveryCode() {
    final number = _random.nextInt(9000) + 1000;
    return 'DEL-$number';
  }
}
