import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';
import '../../features/auth/domain/entities/user_entity.dart';

/// A delivered order waiting for its "rate your order" prompt.
class PendingRating {
  final DateTime deliveredAt;
  final int totalMinor;

  const PendingRating({required this.deliveredAt, required this.totalMinor});
}

class LocalStorage {
  final FlutterSecureStorage _storage;

  const LocalStorage(this._storage);

  Future<void> saveUser(UserEntity user) async {
    await _storage.write(key: StorageKeys.userId, value: user.id);
    await _storage.write(key: StorageKeys.userRole, value: user.role);
  }

  /// Null means the user has never logged in on this device (guest).
  Future<String?> getUserId() => _storage.read(key: StorageKeys.userId);

  Future<UserEntity?> getUser() async {
    final id = await _storage.read(key: StorageKeys.userId);
    final role = await _storage.read(key: StorageKeys.userRole);
    if (id != null && role != null) {
      return UserEntity(id: id, role: role);
    }
    return null;
  }

  Future<void> clearAll() => _storage.deleteAll();

  // ─── Pending rating prompts ─────────────────────────────────────────────────

  /// [totalMinor] is stored alongside so a refund started from the prompt
  /// knows the order amount without another fetch.
  Future<void> savePendingRating(
    String orderId,
    DateTime deliveredAt,
    int totalMinor,
  ) => _storage.write(
    key: '${StorageKeys.pendingRatingPrefix}$orderId',
    value: jsonEncode({
      'deliveredAt': deliveredAt.toIso8601String(),
      'totalMinor': totalMinor,
    }),
  );

  Future<List<String>> getPendingRatingOrderIds() async {
    final all = await _storage.readAll();
    return all.keys
        .where((k) => k.startsWith(StorageKeys.pendingRatingPrefix))
        .map((k) => k.substring(StorageKeys.pendingRatingPrefix.length))
        .toList();
  }

  Future<PendingRating?> getPendingRating(String orderId) async {
    final raw = await _storage.read(
      key: '${StorageKeys.pendingRatingPrefix}$orderId',
    );
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final deliveredAt = DateTime.tryParse(
        json['deliveredAt'] as String? ?? '',
      );
      if (deliveredAt == null) return null;
      return PendingRating(
        deliveredAt: deliveredAt,
        totalMinor: (json['totalMinor'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearPendingRating(String orderId) =>
      _storage.delete(key: '${StorageKeys.pendingRatingPrefix}$orderId');
}
