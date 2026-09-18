import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/rsc_image.dart';
import '../../../../core/di/injection.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../domain/entities/daily_special.dart';
import '../../domain/repositories/daily_specials_repository.dart';
import 'menu_item_card.dart' show MenuItemCard;

class DailySpecialsCarousel extends StatefulWidget {
  const DailySpecialsCarousel({super.key});

  @override
  State<DailySpecialsCarousel> createState() => _DailySpecialsCarouselState();
}

class _DailySpecialsCarouselState extends State<DailySpecialsCarousel> {
  final _repository = getIt<DailySpecialsRepository>();
  final _pageController = PageController(viewportFraction: 0.44);
  List<DailySpecial> _specials = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final specials = await _repository.getDailySpecials();
    if (!mounted) return;
    setState(() => _specials = specials);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_specials.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  '🔥 ${AppStrings.dailySpecials}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(
                  RouteNames.dailySpecialsList,
                  extra: _specials,
                ),
                child: const Text(
                  AppStrings.viewAll,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: _specials.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 12),
              child: DailySpecialCard(special: _specials[index]),
            ),
          ),
        ),
        if (_specials.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _specials.length,
                effect: WormEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: AppColors.navy,
                  dotColor: AppColors.divider,
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class DailySpecialCard extends StatelessWidget {
  const DailySpecialCard({super.key, required this.special});

  final DailySpecial special;

  void _addToCart(BuildContext context) {
    context.read<CartCubit>().addItem(
      CartItemEntity(
        id: CartCubit.generateId(),
        menuItemId: special.menuItemRef.id,
        outletId: special.menuItemRef.outletId,
        outletName: special.outletName,
        outletEmoji: MenuItemCard.emojiForItemName(special.menuItemRef.name),
        itemNameSnapshot: special.menuItemRef.name,
        itemImageUrl: special.menuItemRef.imageUrl ?? '',
        unitPrice: special.discountedPrice,
        basePrice: special.originalPrice,
        quantity: 1,
        selectedModifiers: const [],
      ),
    );

    AppSnackbar.show(
      context,
      message: '${special.menuItemRef.name} ${AppStrings.itemAddedToCart}',
      emoji: '✓',
      type: AppSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.rscPanel,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image + badge ────────────────────────────────────────────────
          SizedBox(
            height: 108,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RscImage(
                  imageUrl: special.menuItemRef.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fallback: Container(
                    color: const Color(0xFFFFF3E0),
                    child: Center(
                      child: Text(
                        MenuItemCard.emojiForItemName(special.menuItemRef.name),
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: special.isTodaysPick
                          ? Colors.black.withValues(alpha: 0.75)
                          : AppColors.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      special.isTodaysPick
                          ? AppStrings.todaysPick
                          : '${special.discountPercent}% OFF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Info ─────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        special.menuItemRef.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        special.menuItemRef.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatNaira(special.discountedPrice),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                            Text(
                              formatNaira(special.originalPrice),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(context),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.navy,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
