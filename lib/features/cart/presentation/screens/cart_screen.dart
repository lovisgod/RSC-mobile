import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../../home/presentation/widgets/menu_item_card.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_event.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final cart = cartState.cart;
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App bar ────────────────────────────────────────────
                _CartAppBar(itemCount: cart.totalItemCount),

                // ── Body ───────────────────────────────────────────────
                if (cart.items.isEmpty)
                  const Expanded(child: _EmptyCartBody())
                else ...[
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: _buildOutletGroups(context, cart),
                    ),
                  ),
                  _CartSummary(cart: cart),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildOutletGroups(BuildContext context, CartEntity cart) {
    final grouped = cart.itemsGroupedByOutlet;
    final widgets = <Widget>[];

    for (final outletId in grouped.keys) {
      final items = grouped[outletId]!;
      final first = items.first;

      widgets.add(_OutletHeader(
        emoji: first.outletEmoji,
        name: first.outletName,
      ));

      for (var i = 0; i < items.length; i++) {
        widgets.add(_CartItemRow(item: items[i]));
        if (i < items.length - 1) {
          widgets.add(const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.divider,
          ));
        }
      }

      widgets.add(const Divider(height: 1, color: AppColors.divider));
    }

    return widgets;
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _CartAppBar extends StatelessWidget {
  const _CartAppBar({required this.itemCount});

  final int itemCount;

  void _showClearConfirmSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<CartCubit>(),
        child: const _ClearCartSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          // Back → home tab
          GestureDetector(
            onTap: () =>
                context.read<ShellBloc>().add(const ShellTabChanged(0)),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
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

          // Title
          Expanded(
            child: Text(
              AppStrings.unifiedCart,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Item count badge
          if (itemCount > 0) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$itemCount ${AppStrings.items}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Clear All
            GestureDetector(
              onTap: () => _showClearConfirmSheet(context),
              child: const Text(
                AppStrings.clearAll,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClearCartSheet extends StatelessWidget {
  const _ClearCartSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.clearCart,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.clearCartMessage,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy),
                      shape: const StadiumBorder(),
                      minimumSize: const Size(0, 50),
                    ),
                    child: const Text(
                      AppStrings.cancel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: AppStrings.clearAll,
                    backgroundColor: AppColors.error,
                    onPressed: () {
                      context.read<CartCubit>().clearCart();
                      Navigator.of(context).pop();
                      AppSnackbar.show(
                        context,
                        message: AppStrings.cartCleared,
                        emoji: '🗑️',
                        type: AppSnackbarType.success,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyCartBody extends StatelessWidget {
  const _EmptyCartBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.iconCart, width: 100, height: 100),
            const SizedBox(height: 24),
            const Text(
              AppStrings.yourCartIsEmpty,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              AppStrings.cartEmptySubtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: AppStrings.browseOutlets,
              backgroundColor: AppColors.navy,
              onPressed: () =>
                  context.read<ShellBloc>().add(const ShellTabChanged(0)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Outlet group header ───────────────────────────────────────────────────────

class _OutletHeader extends StatelessWidget {
  const _OutletHeader({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart item row ─────────────────────────────────────────────────────────────

class _CartItemRow extends StatelessWidget {
  const _CartItemRow({required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final lineTotal = item.unitPrice * item.quantity;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                MenuItemCard.emojiForItemName(item.itemNameSnapshot),
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemNameSnapshot,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedModifiers.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '+ ${item.selectedModifiers.map((m) => m.name).join(', ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  '${formatNaira(item.unitPrice)} each',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Qty controls + line total
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OutlineCircleButton(
                    icon: Icons.remove,
                    onTap: () => cubit.decrementQuantity(item.id),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _OutlineCircleButton(
                    icon: Icons.add,
                    onTap: () => cubit.incrementQuantity(item.id),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Text(
                formatNaira(lineTotal),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutlineCircleButton extends StatelessWidget {
  const _OutlineCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.inputBorder, width: 1.5),
        ),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Cart summary ──────────────────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart});

  final CartEntity cart;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn =
        context.watch<ShellBloc>().state.isAuthenticated;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _SummaryRow(
              label: AppStrings.subtotal,
              value: formatNaira(cart.subtotal),
              isTotal: false,
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              label: AppStrings.vatLabel,
              value: formatNaira(cart.vat),
              isTotal: false,
              labelStyle: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
              valueStyle: const TextStyle(
                  fontSize: 14, color: AppColors.textSecondary),
            ),
            const Divider(height: 16, color: AppColors.divider),
            _SummaryRow(
              label: AppStrings.estimatedTotal,
              value: formatNaira(cart.estimatedTotal),
              isTotal: true,
            ),
            const SizedBox(height: 14),
            AppButton(
              label: AppStrings.proceedToCheckout,
              backgroundColor:
                  isLoggedIn ? AppColors.navy : AppColors.textHint,
              onPressed: isLoggedIn
                  ? () => context.push(
                        RouteNames.checkout,
                        extra: {'cart': cart},
                      )
                  : null,
            ),
            if (!isLoggedIn) ...[
              const SizedBox(height: 6),
              const Text(
                AppStrings.pleaseLoginToOrder,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isTotal,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final bool isTotal;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final defaultLabel = TextStyle(
      fontSize: isTotal ? 15 : 14,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    final defaultValue = TextStyle(
      fontSize: isTotal ? 15 : 14,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
      color: isTotal ? AppColors.primary : AppColors.textPrimary,
    );

    return Row(
      children: [
        Expanded(
          child: Text(label, style: labelStyle ?? defaultLabel),
        ),
        Text(value, style: valueStyle ?? defaultValue),
      ],
    );
  }
}
