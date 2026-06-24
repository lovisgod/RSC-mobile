import 'dart:math';

class User {
  final String id;
  final String name;
  final String phone;
  final String? email;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, min(2, trimmed.length)).toUpperCase();
  }
}
