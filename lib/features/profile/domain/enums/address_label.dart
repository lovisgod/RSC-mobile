import '../../../../core/constants/app_strings.dart';

enum AddressLabel { home, work, other }

extension AddressLabelExtension on AddressLabel {
  String get displayName {
    switch (this) {
      case AddressLabel.home:
        return AppStrings.labelHome;
      case AddressLabel.work:
        return AppStrings.labelWork;
      case AddressLabel.other:
        return AppStrings.labelOther;
    }
  }

  String get emoji {
    switch (this) {
      case AddressLabel.home:
        return '🏠';
      case AddressLabel.work:
        return '💼';
      case AddressLabel.other:
        return '📍';
    }
  }

  static AddressLabel fromString(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return AddressLabel.home;
      case 'work':
        return AddressLabel.work;
      default:
        return AddressLabel.other;
    }
  }
}
