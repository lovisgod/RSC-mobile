import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/rsc_image.dart';
import '../../../menu/domain/entities/outlet.dart';

const ColorFilter _greyscaleFilter = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

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
    final isOnline = outlet.isOnline;

    return IgnorePointer(
      ignoring: !isOnline,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: isOnline ? 1.0 : 0.5,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── TOP: outlet image (or colored fallback) ──────────────
                SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _ImageArea(
                          outlet: outlet,
                          emoji: emoji,
                          cardColor: cardColor,
                          isOnline: isOnline,
                        ),
                      ),
                      if (isOnline && outlet.isFeatured)
                        const Positioned(
                          top: 12,
                          left: 12,
                          child: _PopularBadge(),
                        ),
                      if (!isOnline)
                        const Positioned(
                          top: 12,
                          left: 12,
                          child: _UnavailableBadge(),
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
          ),
        ),
      ),
    );
  }
}

// ── Image area ────────────────────────────────────────────────────────────────

class _ImageArea extends StatelessWidget {
  const _ImageArea({
    required this.outlet,
    required this.emoji,
    required this.cardColor,
    required this.isOnline,
  });

  final Outlet outlet;
  final String emoji;
  final Color cardColor;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final image = RscImage(
      imageUrl: outlet.imageUrl,
      width: double.infinity,
      height: 160,
      fallback: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: cardColor)),
          Center(child: Text(emoji, style: const TextStyle(fontSize: 72))),
        ],
      ),
    );

    if (isOnline) return image;
    return ColorFiltered(colorFilter: _greyscaleFilter, child: image);
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

// ── Unavailable badge ─────────────────────────────────────────────────────────

class _UnavailableBadge extends StatelessWidget {
  const _UnavailableBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.neutralGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        AppStrings.currentlyUnavailable,
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

        // RIGHT: Order Now (orange bold) or Unavailable (gray)
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              outlet.isOnline ? AppStrings.orderNow : AppStrings.unavailable,
              style: TextStyle(
                color: outlet.isOnline
                    ? AppColors.primary
                    : AppColors.neutralGray,
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
