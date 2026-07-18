import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/placeholder_image_util.dart';
import '../../../../core/widgets/rsc_image.dart';
import '../../../menu/domain/entities/menu_item.dart';

const ColorFilter _greyscaleFilter = ColorFilter.matrix([
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.item,
    required this.outletIsOnline,
    this.onAddTap,
  });

  final MenuItem item;

  /// Whether the parent outlet is online — passed in by the caller, never
  /// fetched inside this widget.
  final bool outletIsOnline;
  final VoidCallback? onAddTap;

  bool get _isUnavailable => !item.isAvailable || !outletIsOnline;

  @override
  Widget build(BuildContext context) {
    final unavailable = _isUnavailable;

    final thumbnail = RscImage(
      imageUrl: item.imageUrl,
      width: 80,
      height: 80,
      borderRadius: BorderRadius.circular(12),
      fallback: Container(
        color: const Color(0xFFFFF3E0),
        child: Center(
          child: Text(
            emojiForItemName(item.name),
            style: const TextStyle(fontSize: 36),
          ),
        ),
      ),
    );

    return Opacity(
      opacity: unavailable ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            unavailable
                ? ColorFiltered(colorFilter: _greyscaleFilter, child: thumbnail)
                : thumbnail,
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: unavailable
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: unavailable
                          ? AppColors.textHint
                          : AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatNaira(item.price),
                    style: unavailable
                        ? AppTextStyles.price.copyWith(
                            color: AppColors.textHint,
                          )
                        : AppTextStyles.price,
                  ),
                  if (!item.isAvailable) ...[
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.currentlyUnavailable,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Add button
            GestureDetector(
              onTap: unavailable ? null : onAddTap,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: unavailable ? AppColors.neutralGray : AppColors.navy,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  unavailable ? Icons.block : Icons.add,
                  color: Colors.white,
                  size: unavailable ? 16 : 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String emojiForItemName(String name) {
    final n = name.toLowerCase();
    if (n.contains('suya')) return '🔥';
    if (n.contains('chicken')) return '🍗';
    if (n.contains('tilapia') || n.contains('fish')) return '🐟';
    if (n.contains('rib') || n.contains('pork')) return '🥩';
    if (n.contains('beef') || n.contains('meat') || n.contains('smash'))
      return '🥩';
    if (n.contains('burger')) return '🍔';
    if (n.contains('jollof') || n.contains('fried rice')) return '🍛';
    if (n.contains('rice')) return '🍚';
    if (n.contains('pounded') || n.contains('egusi') || n.contains('soup'))
      return '🍲';
    if (n.contains('coleslaw') || n.contains('salad')) return '🥗';
    if (n.contains('plantain') || n.contains('dodo')) return '🍌';
    if (n.contains('fries') || n.contains('chips')) return '🍟';
    if (n.contains('ring')) return '🧅';
    if (n.contains('sushi') || n.contains('roll') || n.contains('maki'))
      return '🍣';
    if (n.contains('gyoza') || n.contains('dumpling') || n.contains('wonton'))
      return '🥟';
    if (n.contains('edamame') || n.contains('bean')) return '🫛';
    if (n.contains('ramen') || n.contains('noodle')) return '🍜';
    if (n.contains('pad thai') || n.contains('thai')) return '🍜';
    if (n.contains('miso') || n.contains('broth')) return '🍵';
    if (n.contains('milkshake') || n.contains('shake')) return '🥛';
    if (n.contains('water') || n.contains('juice') || n.contains('drink'))
      return '🥤';
    if (n.contains('chapman')) return '🍹';
    if (n.contains('catfish')) return '🐠';
    if (n.contains('ofe') || n.contains('nsala')) return '🍲';
    // No semantic match — fall back to a deterministic placeholder emoji so the
    // same item always looks consistent across screens.
    return PlaceholderImageUtil.getPlaceholderEmoji(name);
  }
}
