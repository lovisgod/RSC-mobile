import 'dart:math';

abstract final class IdGenerator {
  static final Random _random = Random.secure();

  /// RFC 4122 version 4 UUID. Used as the Idempotency-Key for
  /// /payments/initiate — doesn't need a package, just uniqueness and
  /// enough entropy that two checkout attempts never collide.
  static String uuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant 10xx
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
