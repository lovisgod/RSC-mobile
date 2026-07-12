import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../checkout/domain/services/pending_reorder_holder.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_event.dart';
import '../../../track/presentation/cubit/track_cubit.dart';
import '../../domain/entities/order_history_entity.dart';
import '../cubit/order_history_cubit.dart';

class OrderHistoryCard extends StatefulWidget {
  const OrderHistoryCard({super.key, required this.order});

  final OrderHistoryEntity order;

  @override
  State<OrderHistoryCard> createState() => _OrderHistoryCardState();
}

class _OrderHistoryCardState extends State<OrderHistoryCard> {
  static const _deliveryModeColor = Color(0xFF2196F3);

  bool _isTracking = false;

  void _handleCardTap() {
    final order = widget.order;
    // Active orders are only ever tracked via the explicit "Track" button
    // below — the card itself no longer switches tabs on tap.
    if (order.isActive) return;
    context.read<OrderHistoryCubit>().loadOrderDetail(order.id);
    context.push(RouteNames.orderDetails, extra: order.id);
  }

  Future<void> _handleTrack() async {
    if (_isTracking) return;
    setState(() => _isTracking = true);

    final trackCubit = getIt<TrackCubit>();
    await trackCubit.loadSpecificOrder(widget.order.id);

    if (!mounted) return;
    setState(() => _isTracking = false);

    final loaded = trackCubit.state.activeOrder;
    if (trackCubit.state.hasActiveOrder && loaded?.id == widget.order.id) {
      context.read<ShellBloc>().add(const ShellTabChanged(3));
    } else {
      AppSnackbar.show(
        context,
        message: trackCubit.state.error ?? AppStrings.trackOrderFailed,
        type: AppSnackbarType.error,
      );
    }
  }

  Future<void> _handleReorder() async {
    final orderHistoryCubit = context.read<OrderHistoryCubit>();
    // The flag lives on the cubit (not this widget) so it can't get stuck
    // once this card is hidden — rather than disposed — inside the shell's
    // IndexedStack after navigating to the Cart tab.
    if (orderHistoryCubit.state.isReordering) return;

    final reorderData = await orderHistoryCubit.reorder(widget.order.id);

    if (reorderData == null) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message:
            orderHistoryCubit.state.reorderError ?? AppStrings.reorderFailed,
        type: AppSnackbarType.error,
      );
      return;
    }

    if (!mounted) return;
    context.go(RouteNames.home);
    context.read<ShellBloc>().add(const ShellTabChanged(2));
    AppSnackbar.show(
      context,
      message: AppStrings.itemsAddedToCart,
      emoji: '',
      backgroundColor: AppColors.navy,
    );
    getIt<PendingReorderHolder>().stage(reorderData);
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final moreCount = order.additionalItemsCount;
    final historyState = context.watch<OrderHistoryCubit>().state;
    final isReorderingThis =
        historyState.isReordering && historyState.reorderingOrderId == order.id;

    return GestureDetector(
      onTap: _handleCardTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: date + delivery mode ─────────────────────────────
            Row(
              children: [
                Text(
                  formatDateTime(order.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _deliveryModeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.deliveryMode,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _deliveryModeColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── First item ─────────────────────────────────────────────────
            if (order.firstItemSummary.isNotEmpty)
              Text(
                order.firstItemSummary,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            if (moreCount > 0) ...[
              const SizedBox(height: 2),
              Text(
                '+ $moreCount ${moreCount == 1 ? AppStrings.moreItemSuffix : AppStrings.moreItemsSuffix}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),

            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),

            // ── Bottom row: grand total + status-specific actions ──────────
            Row(
              children: [
                Text(
                  formatNaira(order.total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (order.status == 'CANCELLED') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PillButton(
                    label: AppStrings.viewDetails,
                    backgroundColor: AppColors.navy,
                    isLoading: false,
                    onTap: _handleCardTap,
                  ),
                ] else if (order.isActive) ...[
                  _PillButton(
                    label: AppStrings.trackOrder,
                    leadingEmoji: '📍',
                    backgroundColor: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    isLoading: _isTracking,
                    onTap: _handleTrack,
                  ),
                  const SizedBox(width: 8),
                  _PillButton(
                    label: AppStrings.reorder,
                    backgroundColor: AppColors.navy,
                    isLoading: isReorderingThis,
                    onTap: _handleReorder,
                  ),
                ] else
                  _PillButton(
                    label: AppStrings.reorder,
                    backgroundColor: AppColors.navy,
                    isLoading: isReorderingThis,
                    onTap: _handleReorder,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pill button ────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.backgroundColor,
    required this.isLoading,
    required this.onTap,
    this.leadingEmoji,
    this.fontWeight = FontWeight.w600,
  });

  final String label;
  final Color backgroundColor;
  final bool isLoading;
  final VoidCallback onTap;
  final String? leadingEmoji;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: isLoading ? 0.6 : 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingEmoji != null) ...[
                    Text(leadingEmoji!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: fontWeight,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
