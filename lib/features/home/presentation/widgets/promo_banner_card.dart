import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/rsc_image.dart';
import '../../domain/entities/promo_offer.dart';

/// Poster-style promo card matching the DineOut NG "HUNGRY FOR MORE?"
/// reference design: near-black-green gradient base, a full-bleed food
/// photo on the right blended into the background, a large circular
/// "UP TO X% OFF" badge, and a slanted ribbon directly under it carrying
/// the promo code (or a fallback line when there's no code to show).
class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, required this.promo});

  final PromoOffer promo;

  /// Lime-green accent used for the second headline word and the tag
  /// watermarks — matches the reference asset's "MORE?" color, which isn't
  /// one of the app's existing brand-green tokens (those all skew closer to
  /// a saturated mid-green rather than this yellow-leaning lime).
  static const _accentLime = Color(0xFFA6D93C);

  void _onTap(BuildContext context) {
    // promo.deepLink isn't defined on the backend yet (always null today) —
    // PromoDetailScreen is the destination until a real format exists to
    // parse and route from here instead.
    context.push(RouteNames.promoDetailPath(promo.id), extra: promo);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = (promo.imageUrl ?? '').isNotEmpty;
    final words = promo.title.trim().split(RegExp(r'\s+'));
    final hasSecondLine = words.length > 1 && words.first.isNotEmpty;
    final firstLine = (hasSecondLine
            ? words.sublist(0, words.length - 1)
            : words)
        .join(' ')
        .toUpperCase();
    final secondLine = hasSecondLine ? words.last.toUpperCase() : '';

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 136,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(22)),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF061A0C), Color(0xFF0B2C15)],
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final photoWidth = cardWidth * 0.62;
            final textRight = hasImage ? (cardWidth - photoWidth + 12) : 20.0;

            return Stack(
              children: [
                // Decorative low-opacity tag watermarks, poster texture.
                Positioned(
                  left: -4,
                  top: -8,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      Icons.sell_rounded,
                      size: 46,
                      color: _accentLime.withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: -12,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: Icon(
                      Icons.sell_rounded,
                      size: 38,
                      color: _accentLime.withValues(alpha: 0.14),
                    ),
                  ),
                ),
                Positioned(
                  left: 62,
                  top: 18,
                  child: Transform.rotate(
                    angle: 0.18,
                    child: Icon(
                      Icons.sell_rounded,
                      size: 26,
                      color: _accentLime.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  left: 6,
                  bottom: 44,
                  child: Transform.rotate(
                    angle: 0.12,
                    child: Icon(
                      Icons.sell_rounded,
                      size: 24,
                      color: _accentLime.withValues(alpha: 0.12),
                    ),
                  ),
                ),

                // Photo bleeding in from the right, fading into the bg.
                if (hasImage)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: photoWidth,
                    child: ShaderMask(
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.0, 0.3, 1.0],
                        colors: [Colors.transparent, Colors.black, Colors.black],
                      ).createShader(rect),
                      blendMode: BlendMode.dstIn,
                      child: RscImage(
                        imageUrl: promo.imageUrl,
                        width: photoWidth,
                        height: 136,
                        fit: BoxFit.cover,
                        fallback: const SizedBox.shrink(),
                      ),
                    ),
                  ),

                // Headline / subtitle block, sized to fill the card height.
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  right: textRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (hasSecondLine)
                        Text(
                          secondLine,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _accentLime,
                            fontSize: 20,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      Transform(
                        alignment: Alignment.centerLeft,
                        transform: Matrix4.skewX(-0.15),
                        child: Text(
                          promo.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Circular "UP TO X% OFF" badge + ribbon, grouped so the
                // ribbon sits flush under the circle instead of drifting to
                // the card's corner.
                if (promo.discountPercent > 0)
                  Positioned(
                    right: 12,
                    top: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF04140A).withValues(
                              alpha: 0.94,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'UP TO',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              Text(
                                '${promo.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                              const Text(
                                'OFF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.skewX(-0.24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.navy,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                promo.code.isNotEmpty
                                    ? promo.code.toUpperCase()
                                    : 'LIMITED TIME',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
