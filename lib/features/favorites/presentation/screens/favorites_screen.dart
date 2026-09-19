import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/rsc_image.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../home/presentation/widgets/menu_item_card.dart' show MenuItemCard;
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_event.dart';
import '../../domain/entities/favorite_menu_item.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesCubit>().loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _FavoritesAppBar(),
            Expanded(
              child: BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, state) {
                  if (state.items.isEmpty) {
                    return const _EmptyFavoritesState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _FavoriteItemCard(item: state.items[index]),
                      );
                    },
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

class _FavoritesAppBar extends StatelessWidget {
  const _FavoritesAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () =>
                context.read<ShellBloc>().add(const ShellTabChanged(0)),
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
            AppStrings.tabFavorites,
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

// ── Favorite item card ───────────────────────────────────────────────────────

class _FavoriteItemCard extends StatelessWidget {
  const _FavoriteItemCard({required this.item});

  final FavoriteMenuItem item;

  void _addToCart(BuildContext context) {
    context.read<CartCubit>().addItem(
      CartItemEntity(
        id: CartCubit.generateId(),
        menuItemId: item.itemId,
        outletId: item.outletId,
        outletName: item.outletName,
        outletEmoji: MenuItemCard.emojiForItemName(item.name),
        itemNameSnapshot: item.name,
        itemImageUrl: item.imageUrl ?? '',
        unitPrice: item.price,
        basePrice: item.price,
        quantity: 1,
        selectedModifiers: const [],
      ),
    );

    AppSnackbar.show(
      context,
      message: '${item.name} ${AppStrings.itemAddedToCart}',
      emoji: '✓',
      type: AppSnackbarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RscImage(
            imageUrl: item.imageUrl,
            width: 72,
            height: 72,
            borderRadius: BorderRadius.circular(12),
            fallback: Container(
              color: const Color(0xFFFFF3E0),
              child: Center(
                child: Text(
                  MenuItemCard.emojiForItemName(item.name),
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
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
                  item.outletName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  formatNaira(item.price),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () =>
                    context.read<FavoritesCubit>().toggleFavorite(item),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.rscDanger,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _addToCart(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

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
                Icons.favorite_border_rounded,
                size: 34,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              AppStrings.noFavoritesYet,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noFavoritesYetDescription,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
