import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class LocalStorage {
  final FlutterSecureStorage _storage;

  const LocalStorage(this._storage);

  Future<void> saveUser(UserEntity user) async {
    await _storage.write(key: StorageKeys.userId, value: user.id);
    await _storage.write(key: StorageKeys.userRole, value: user.role);
  }

  Future<UserEntity?> getUser() async {
    final id = await _storage.read(key: StorageKeys.userId);
    final role = await _storage.read(key: StorageKeys.userRole);
    if (id != null && role != null) {
      return UserEntity(id: id, role: role);
    }
    return null;
  }

  Future<void> clearAll() => _storage.deleteAll();
}
