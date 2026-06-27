import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../menu/domain/entities/outlet.dart';

class OutletCard extends StatelessWidget {
  const OutletCard({
    super.key,
    required this.outlet,
    required this.emoji,
    required this.cardColor,
    required this.onTap,
  });

  final Outlet outlet;
  final String emoji;
  final Color cardColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── TOP: colored image section ───────────────────────────
                SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      Positioned.fill(child: ColoredBox(color: cardColor)),
                      Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 72),
                        ),
                      ),
                      if (outlet.isOnline)
                        const Positioned(
                          top: 12,
                          left: 12,
                          child: _PopularBadge(),
                        ),
                    ],
                  ),
                ),

                // ── BOTTOM: white info section ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outlet.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        outlet.cuisineType,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      _BottomRow(outlet: outlet),
                    ],
                  ),
                ),
              ],
            ),

            // ── Closed overlay ───────────────────────────────────────────
            if (!outlet.isOnline)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        AppStrings.closed,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Popular badge ─────────────────────────────────────────────────────────────

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        AppStrings.popular,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Bottom info row ───────────────────────────────────────────────────────────

class _BottomRow extends StatelessWidget {
  const _BottomRow({required this.outlet});

  final Outlet outlet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // LEFT: star + rating (both orange)
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.primary,
                size: 15,
              ),
              const SizedBox(width: 3),
              Text(
                outlet.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // CENTER: clock + time (both gray)
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppColors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${outlet.deliveryTimeMins}–${outlet.deliveryTimeMins + 10} min',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        // RIGHT: Order Now (orange bold)
        if (outlet.isOnline)
          Expanded(
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                AppStrings.orderNow,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
