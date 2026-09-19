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
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.rscPanel,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Layer 1: full-bleed image ────────────────────────────
                Positioned.fill(
                  child: isOnline
                      ? _ImageArea(
                          outlet: outlet,
                          emoji: emoji,
                          cardColor: cardColor,
                        )
                      : ColorFiltered(
                          colorFilter: _greyscaleFilter,
                          child: _ImageArea(
                            outlet: outlet,
                            emoji: emoji,
                            cardColor: cardColor,
                          ),
                        ),
                ),

                // ── Layer 2: bottom-to-top dark scrim ────────────────────
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── Layer 3: name + cuisine overlaid on image ────────────
                Positioned(
                  top: 12,
                  left: 12,
                  right: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        outlet.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        outlet.cuisineType,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ── Layer 4: popular / unavailable badge ─────────────────
                if (isOnline && outlet.isFeatured)
                  const Positioned(top: 8, right: 8, child: _PopularBadge()),
                if (!isOnline)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: _UnavailableBadge(),
                  ),

                // ── Layer 5: order-now bar ────────────────────────────────
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: _OrderNowBar(isOnline: isOnline),
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
  });

  final Outlet outlet;
  final String emoji;
  final Color cardColor;

  @override
  Widget build(BuildContext context) {
    return RscImage(
      imageUrl: outlet.imageUrl,
      width: double.infinity,
      height: double.infinity,
      fallback: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: cardColor)),
          Center(child: Text(emoji, style: const TextStyle(fontSize: 56))),
        ],
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
        color: AppColors.navy,
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

// ── Order-now bar ─────────────────────────────────────────────────────────────

class _OrderNowBar extends StatelessWidget {
  const _OrderNowBar({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 6, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isOnline
                  ? AppStrings.orderNow.toUpperCase()
                  : AppStrings.unavailable.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.navy : AppColors.neutralGray,
            ),
            child: Icon(
              isOnline ? Icons.arrow_forward_rounded : Icons.block,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
