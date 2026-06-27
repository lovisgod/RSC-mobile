import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/domain/entities/selected_modifier_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../menu/domain/entities/menu_item.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/modifier_group_card.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.menuItem,
    required this.outlet,
    this.fromSearch = false,
  });

  final MenuItem menuItem;
  final Outlet outlet;

  /// True when navigated from search — "Add" pops instead of going home.
  final bool fromSearch;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  /// groupId → set of selected modifier IDs in that group
  late Map<String, Set<String>> _selectedIds;
  int _quantity = 1;

  /// Set when this item is already in the cart; drives "Update Cart" mode.
  String? _editingCartItemId;

  bool get _isEditing => _editingCartItemId != null;

  @override
  void initState() {
    super.initState();

    // Initialize modifier selection maps
    _selectedIds = {
      for (final g in widget.menuItem.modifierGroups) g.id: {},
    };

    // Check if item already exists in cart
    final cartItems = context.read<CartCubit>().state.cart.items;
    final existing = cartItems
        .where((e) => e.menuItemId == widget.menuItem.id)
        .firstOrNull;

    if (existing != null) {
      _editingCartItemId = existing.id;
      _quantity = existing.quantity;

      // Pre-check modifiers from the existing cart item
      for (final sel in existing.selectedModifiers) {
        for (final group in widget.menuItem.modifierGroups) {
          if (group.modifiers.any((m) => m.id == sel.modifierId)) {
            _selectedIds[group.id]!.add(sel.modifierId);
            break;
          }
        }
      }
    }
  }

  // ── Computed state ─────────────────────────────────────────────────────────

  double get _totalPrice {
    double modTotal = 0;
    for (final group in widget.menuItem.modifierGroups) {
      for (final mod in group.modifiers) {
        if (_selectedIds[group.id]?.contains(mod.id) == true) {
          modTotal += mod.priceDelta;
        }
      }
    }
    return (widget.menuItem.price + modTotal) * _quantity;
  }

  bool get _canAdd {
    for (final group in widget.menuItem.modifierGroups) {
      if (group.isRequired && (_selectedIds[group.id]?.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _toggle(String groupId, String modifierId, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds[groupId]!.add(modifierId);
      } else {
        _selectedIds[groupId]!.remove(modifierId);
      }
    });
  }

  List<SelectedModifierEntity> _buildFlatModifiers() {
    final flat = <SelectedModifierEntity>[];
    for (final group in widget.menuItem.modifierGroups) {
      for (final mod in group.modifiers) {
        if (_selectedIds[group.id]?.contains(mod.id) == true) {
          flat.add(SelectedModifierEntity(
            modifierId: mod.id,
            name: mod.name,
            priceDelta: mod.priceDelta,
          ));
        }
      }
    }
    return flat;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _onAddToCart() {
    final flat = _buildFlatModifiers();
    final unitPrice =
        widget.menuItem.price + flat.fold(0.0, (s, m) => s + m.priceDelta);

    context.read<CartCubit>().addItem(CartItemEntity(
          id: CartCubit.generateId(),
          menuItemId: widget.menuItem.id,
          outletId: widget.outlet.id,
          outletName: widget.outlet.name,
          outletEmoji: _outletEmoji(widget.outlet.id),
          itemNameSnapshot: widget.menuItem.name,
          itemImageUrl: widget.menuItem.imageUrl,
          unitPrice: unitPrice,
          basePrice: widget.menuItem.price,
          quantity: _quantity,
          selectedModifiers: flat,
        ));

    AppSnackbar.show(
      context,
      message: '${widget.menuItem.name} ${AppStrings.itemAddedToCart}',
      emoji: '✓',
      type: AppSnackbarType.success,
    );

    if (widget.fromSearch) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  void _onUpdateCart() {
    final flat = _buildFlatModifiers();
    final unitPrice =
        widget.menuItem.price + flat.fold(0.0, (s, m) => s + m.priceDelta);

    context.read<CartCubit>().updateItem(
          _editingCartItemId!,
          quantity: _quantity,
          selectedModifiers: flat,
          unitPrice: unitPrice,
        );

    AppSnackbar.show(
      context,
      message: '${widget.menuItem.name} ${AppStrings.updatedInCart}',
      emoji: '✓',
      type: AppSnackbarType.success,
    );

    context.pop();
  }

  static String _outletEmoji(String outletId) {
    const map = <String, String>{
      'f47ac10b-58cc-4372-a567-0e02b2c3d479': '🔥',
      '550e8400-e29b-41d4-a716-446655440000': '🍜',
      '6ba7b810-9dad-11d1-80b4-00c04fd430c8': '🍲',
      '7c9e6679-7425-40de-944b-e07fc1f90ae7': '🍔',
    };
    return map[outletId] ?? '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.menuItem;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          _ItemHeader(item: item, onBack: () => context.pop()),

          // ── Scrollable content ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + live price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        formatNaira(_totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  // Allergen note
                  if (item.allergenNote != null) ...[
                    const SizedBox(height: 14),
                    _AllergenBanner(note: item.allergenNote!),
                  ],

                  // Modifier groups
                  if (item.modifierGroups.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ...item.modifierGroups.map((group) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ModifierGroupCard(
                            group: group,
                            selectedIds:
                                Set.unmodifiable(_selectedIds[group.id] ?? {}),
                            onToggle: (modId, selected) =>
                                _toggle(group.id, modId, selected),
                          ),
                        )),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Fixed bottom bar ──────────────────────────────────────────
          _BottomBar(
            quantity: _quantity,
            canAdd: _canAdd,
            buttonLabel: _isEditing
                ? AppStrings.updateCart
                : AppStrings.addToUnifiedCart,
            onDecrement: () =>
                setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
            onIncrement: () => setState(() => _quantity++),
            onAction: _isEditing ? _onUpdateCart : _onAddToCart,
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ItemHeader extends StatelessWidget {
  const _ItemHeader({required this.item, required this.onBack});

  final MenuItem item;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      color: const Color(0xFFFFF3E0),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 16,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
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
              ),
            ),
            Center(
              child: Text(
                MenuItemCard.emojiForItemName(item.name),
                style: const TextStyle(fontSize: 100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Allergen banner ───────────────────────────────────────────────────────────

class _AllergenBanner extends StatelessWidget {
  const _AllergenBanner({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🍀', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.quantity,
    required this.canAdd,
    required this.buttonLabel,
    required this.onDecrement,
    required this.onIncrement,
    required this.onAction,
  });

  final int quantity;
  final bool canAdd;
  final String buttonLabel;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Quantity selector
              Row(
                children: [
                  _QtyCircleButton(
                    icon: Icons.remove,
                    onTap: quantity > 1 ? onDecrement : null,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  _QtyCircleButton(icon: Icons.add, onTap: onIncrement),
                ],
              ),
              const SizedBox(width: 16),

              // Action button
              Expanded(
                child: AppButton(
                  label: buttonLabel,
                  backgroundColor: AppColors.navy,
                  onPressed: canAdd ? onAction : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyCircleButton extends StatelessWidget {
  const _QtyCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.background,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? Colors.white : AppColors.textHint,
        ),
      ),
    );
  }
}
