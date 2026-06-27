import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../menu/domain/entities/category.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../bloc/outlet_detail_bloc.dart';
import '../bloc/outlet_detail_event.dart';
import '../bloc/outlet_detail_state.dart';
import '../widgets/menu_item_card.dart';

class OutletDetailScreen extends StatelessWidget {
  const OutletDetailScreen({super.key, required this.outlet});

  final Outlet outlet;

  // Per-outlet emoji (same mapping as home screen)
  static const _outletEmojis = <String, String>{
    'f47ac10b-58cc-4372-a567-0e02b2c3d479': '🔥',
    '550e8400-e29b-41d4-a716-446655440000': '🍜',
    '6ba7b810-9dad-11d1-80b4-00c04fd430c8': '🍲',
    '7c9e6679-7425-40de-944b-e07fc1f90ae7': '🍔',
  };

  String get _emoji => _outletEmojis[outlet.id] ?? '🍽️';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Stack(
        children: [
          // ── Navy header with emoji ───────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _CircleBackButton(onTap: () => context.pop()),
                  ),
                  const SizedBox(height: 20),
                  Text(_emoji, style: const TextStyle(fontSize: 84)),
                ],
              ),
            ),
          ),

          // ── White sliding sheet ──────────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.60,
            minChildSize: 0.60,
            maxChildSize: 1.0,
            snap: true,
            snapSizes: const [0.60, 1.0],
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: BlocBuilder<OutletDetailBloc, OutletDetailState>(
                  builder: (context, state) {
                    if (state is OutletDetailLoading ||
                        state is OutletDetailInitial) {
                      return _ShimmerSheet(controller: scrollController);
                    }
                    if (state is OutletDetailError) {
                      return _ErrorSheet(message: state.message);
                    }
                    if (state is OutletDetailLoaded) {
                      return CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          // Drag handle + outlet info
                          SliverToBoxAdapter(
                            child: _OutletInfoSection(outlet: outlet),
                          ),

                          // Sticky category tabs
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _CategoryTabsDelegate(
                              categories: state.categories,
                              selectedId: state.selectedCategoryId,
                              onTap: (id) => context
                                  .read<OutletDetailBloc>()
                                  .add(OutletDetailCategorySelected(id)),
                            ),
                          ),

                          // Menu items
                          if (state.selectedItems.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Text(
                                  AppStrings.noMenuItems,
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = state.selectedItems[index];
                                  return Column(
                                    children: [
                                      MenuItemCard(
                                        item: item,
                                        onAddTap: () => context.push(
                                          RouteNames.itemDetailPath(
                                              outlet.id, item.id),
                                          extra: {
                                            'menuItem': item,
                                            'outlet': outlet,
                                          },
                                        ),
                                      ),
                                      if (index < state.selectedItems.length - 1)
                                        const Divider(
                                          height: 1,
                                          indent: 16,
                                          endIndent: 16,
                                          color: AppColors.divider,
                                        ),
                                    ],
                                  );
                                },
                                childCount: state.selectedItems.length,
                              ),
                            ),

                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.navyDark,
        ),
      ),
    );
  }
}

// ── Outlet info section ───────────────────────────────────────────────────────

class _OutletInfoSection extends StatelessWidget {
  const _OutletInfoSection({required this.outlet});

  final Outlet outlet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Name
          Text(
            outlet.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),

          // Cuisine
          Text(
            outlet.cuisineType,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),

          // Info row
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 15,
                color: AppColors.starRating,
              ),
              const SizedBox(width: 4),
              Text(
                outlet.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${outlet.deliveryTimeMins}–${outlet.deliveryTimeMins + 10} min',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Text('🛵', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              const Text(
                '₦500 delivery',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Category tabs (sticky SliverPersistentHeaderDelegate) ────────────────────

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  const _CategoryTabsDelegate({
    required this.categories,
    required this.selectedId,
    required this.onTap,
  });

  final List<MenuCategory> categories;
  final String selectedId;
  final ValueChanged<String> onTap;

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.surface,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: categories.map((cat) {
                  final selected = cat.id == selectedId;
                  return GestureDetector(
                    onTap: () => onTap(cat.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: selected
                                  ? AppColors.navy
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 2.5,
                            width: selected ? 24 : 0,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryTabsDelegate oldDelegate) =>
      oldDelegate.selectedId != selectedId ||
      oldDelegate.categories != categories;
}

// ── Shimmer sheet ─────────────────────────────────────────────────────────────

class _ShimmerSheet extends StatelessWidget {
  const _ShimmerSheet({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const ShimmerBox(
            height: 22,
            width: 160,
            radius: 8,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 8),
          ),
          const ShimmerBox(
            height: 14,
            width: 220,
            radius: 6,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 8),
          ),
          const ShimmerBox(
            height: 14,
            width: 260,
            radius: 6,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
          ),
          // Tab shimmer
          Row(
            children: [
              const ShimmerBox(
                height: 20,
                width: 70,
                radius: 10,
                margin: EdgeInsets.fromLTRB(16, 0, 8, 0),
              ),
              const ShimmerBox(
                height: 20,
                width: 60,
                radius: 10,
                margin: EdgeInsets.fromLTRB(0, 0, 8, 0),
              ),
              const ShimmerBox(
                height: 20,
                width: 50,
                radius: 10,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Item shimmers
          ...List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  ShimmerBox(height: 80, width: 80, radius: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(height: 14, radius: 6),
                        SizedBox(height: 8),
                        ShimmerBox(height: 12, radius: 5),
                        SizedBox(height: 6),
                        ShimmerBox(height: 14, width: 80, radius: 6),
                      ],
                    ),
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

// ── Error sheet ───────────────────────────────────────────────────────────────

class _ErrorSheet extends StatelessWidget {
  const _ErrorSheet({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              message,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
