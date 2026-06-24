import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.activeIndex,
    required this.isAuthenticated,
    required this.onTabSelected,
    this.userInitials,
  });

  final int activeIndex;
  final bool isAuthenticated;
  final String? userInitials;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildItem(0, Icons.home_outlined, AppStrings.tabHome),
              _buildItem(1, Icons.search_outlined, AppStrings.tabSearch),
              _buildItem(2, Icons.shopping_bag_outlined, AppStrings.tabCart),
              _buildItem(3, Icons.location_on_outlined, AppStrings.tabTrack),
              _buildProfileItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String label) {
    final bool isActive = activeIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPill(
              isActive: isActive,
              child: Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem() {
    final bool isActive = activeIndex == 4;
    final bool showAvatar = isAuthenticated && userInitials != null;

    final Widget iconWidget = showAvatar
        ? Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              userInitials!,
              style: const TextStyle(
                color: AppColors.textOnDark,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        : Icon(
            Icons.person_outline,
            size: 22,
            color: isActive ? AppColors.navActive : AppColors.navInactive,
          );

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(4),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPill(isActive: isActive, child: iconWidget),
            const SizedBox(height: 2),
            Text(
              AppStrings.tabProfile,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.navActive : AppColors.navInactive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPill({required bool isActive, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.navActiveBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
