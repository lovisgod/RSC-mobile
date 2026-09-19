import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../domain/entities/favorite_menu_item.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';

/// Heart toggle shared by every surface that shows a menu item — the outlet
/// menu list, search results, and the item detail page — so favoriting a
/// dish works the same everywhere and stays in sync via [FavoritesCubit].
class FavoriteToggleButton extends StatelessWidget {
  const FavoriteToggleButton({
    super.key,
    required this.item,
    required this.outletId,
    required this.outletName,
    this.size = 20,
  });

  final MenuItem item;
  final String outletId;
  final String outletName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state.isFavorite(item.id);
        return GestureDetector(
          onTap: () => context.read<FavoritesCubit>().toggleFavorite(
            FavoriteMenuItem(
              itemId: item.id,
              outletId: outletId,
              outletName: outletName,
              name: item.name,
              description: item.description,
              price: item.price,
              imageUrl: item.imageUrl,
            ),
          ),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? AppColors.rscDanger : AppColors.textHint,
            size: size,
          ),
        );
      },
    );
  }
}
