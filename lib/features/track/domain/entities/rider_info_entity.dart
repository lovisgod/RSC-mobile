class RiderInfoEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final String vehicleType;
  final String plateNumber;

  const RiderInfoEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.vehicleType,
    required this.plateNumber,
  });

  /// "2349043332345" → "09043332345".
  String get displayPhone {
    final digits = phone.startsWith('+') ? phone.substring(1) : phone;
    if (digits.startsWith('234')) return '0${digits.substring(3)}';
    return digits;
  }

  /// "Percy Rider2" → "PR" (first letter of each word, max 2).
  String get initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  /// "bike" + "ABC-123ASD" → "Bike · ABC-123ASD".
  String get displayVehicle {
    final capitalized = vehicleType.isEmpty
        ? vehicleType
        : '${vehicleType[0].toUpperCase()}${vehicleType.substring(1).toLowerCase()}';
    return '$capitalized · $plateNumber';
  }
}
