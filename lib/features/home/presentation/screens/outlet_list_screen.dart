import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../widgets/outlet_card.dart';

class OutletListScreen extends StatelessWidget {
  const OutletListScreen({super.key, required this.outlets});

  final List<Outlet> outlets;

  static const List<String> _emojis = ['🔥', '🍜', '🍲', '🍔', '🍽️'];
  static const List<Color> _colors = [
    AppColors.outletCardNavy,
    AppColors.outletCardGreen,
    AppColors.navyLight,
    AppColors.navyDark,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: outlets.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: outlets.length,
                      itemBuilder: (context, index) {
                        final outlet = outlets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OutletCard(
                            outlet: outlet,
                            emoji: _emojis[index % _emojis.length],
                            cardColor: _colors[index % _colors.length],
                            onTap: () => context.push(
                              '/outlet/${outlet.id}',
                              extra: outlet,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.navyDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            AppStrings.ourOutlets,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.navActiveBackground,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              AppStrings.noOutletsAvailable,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noOutletsAvailableDescription,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
