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
import '../../../checkout/presentation/cubit/payment_cubit.dart';
import '../../../checkout/presentation/cubit/payment_state.dart';
import '../../../checkout/presentation/screens/payment_webview_screen.dart';
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

  /// Owned by this card, created only for PENDING_PAYMENT orders — the
  /// factory-scoped PaymentCubit isn't provided outside the checkout route.
  PaymentCubit? _paymentCubit;

  @override
  void initState() {
    super.initState();
    if (widget.order.isPendingPayment) {
      _paymentCubit = getIt<PaymentCubit>();
    }
  }

  @override
  void dispose() {
    _paymentCubit?.close();
    super.dispose();
  }

  void _handlePayNow() {
    final cubit = _paymentCubit;
    if (cubit == null) return;
    if (cubit.state.status == PaymentStatus.initiating ||
        cubit.state.status == PaymentStatus.verifying) {
      return;
    }
    cubit.retryPaymentForOrder(widget.order.id);
  }

  void _onPaymentStateChanged(PaymentState pState) {
    final cubit = _paymentCubit;
    if (cubit == null || !mounted) return;

    switch (pState.status) {
      case PaymentStatus.initiated:
        final checkoutUrl = pState.checkoutUrl;
        final reference = pState.reference;
        if (checkoutUrl == null || reference == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: PaymentWebViewScreen(
                checkoutUrl: checkoutUrl,
                reference: reference,
              ),
            ),
          ),
        );
      case PaymentStatus.success:
        context.read<OrderHistoryCubit>().loadOrders();
      case PaymentStatus.failed:
        AppSnackbar.show(
          context,
          message: pState.errorMessage ?? AppStrings.paymentFailed,
          type: AppSnackbarType.error,
        );
      default:
        break;
    }
  }

  void _handleCardTap() {
    final order = widget.order;
    context.read<OrderHistoryCubit>().loadOrderDetail(order.id);
    context.push(RouteNames.orderDetails, extra: order.id);
  }

  Future<void> _handleTrack() async {
    if (_isTracking) return;
    setState(() => _isTracking = true);

    debugPrint('[RSC Track] Tapped Track for order: ${widget.order.id}');

    final trackCubit = getIt<TrackCubit>();
    await trackCubit.loadSpecificOrder(widget.order.id);

    debugPrint(
      '[RSC Track] After load — hasActiveOrder: '
      '${trackCubit.state.hasActiveOrder}',
    );
    debugPrint(
      '[RSC Track] activeOrder id: ${trackCubit.state.activeOrder?.id}',
    );
    debugPrint('[RSC Track] error: ${trackCubit.state.error}');

    if (!mounted) return;
    setState(() => _isTracking = false);

    if (trackCubit.state.error == null &&
        trackCubit.state.activeOrder != null) {
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

    final card = GestureDetector(
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
            // ── Top row: date + delivery mode + status badge ───────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatDateTime(order.createdAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
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
                const SizedBox(width: 6),
                _StatusBadge(status: order.status),
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
                if (order.isPendingPayment) ...[
                  // Payment is the only sensible action here — no Track, no
                  // Re-order until the order is actually paid for.
                  const SizedBox(width: 12),
                  Expanded(
                    child: BlocBuilder<PaymentCubit, PaymentState>(
                      bloc: _paymentCubit,
                      builder: (context, pState) {
                        final isBusy =
                            pState.status == PaymentStatus.initiating ||
                            pState.status == PaymentStatus.verifying;
                        return _PillButton(
                          label: AppStrings.payNow,
                          backgroundColor: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          isLoading: isBusy,
                          expanded: true,
                          onTap: _handlePayNow,
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const Spacer(),
                  if (order.status.toUpperCase() == 'CANCELLED')
                    _PillButton(
                      label: AppStrings.viewDetails,
                      backgroundColor: AppColors.navy,
                      isLoading: false,
                      onTap: _handleCardTap,
                    )
                  else if (order.isActive) ...[
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
              ],
            ),
          ],
        ),
      ),
    );

    final paymentCubit = _paymentCubit;
    if (paymentCubit == null) return card;

    return BlocListener<PaymentCubit, PaymentState>(
      bloc: paymentCubit,
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (_, pState) => _onPaymentStateChanged(pState),
      child: card,
    );
  }
}

// ── Status badge ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground, String label) = switch (status
        .toUpperCase()) {
      'PENDING_PAYMENT' => (
        AppColors.warningLight,
        AppColors.warning,
        AppStrings.statusPendingPayment,
      ),
      'PENDING' => (
        AppColors.neutralGray.withValues(alpha: 0.15),
        AppColors.neutralGray,
        AppStrings.statusPending,
      ),
      'CONFIRMED' => (
        AppColors.info.withValues(alpha: 0.15),
        AppColors.info,
        AppStrings.statusConfirmed,
      ),
      'PARTIALLY_READY' => (
        AppColors.warning.withValues(alpha: 0.15),
        AppColors.warning,
        AppStrings.statusAlmostReady,
      ),
      'READY' => (
        AppColors.success.withValues(alpha: 0.15),
        AppColors.success,
        AppStrings.statusReady,
      ),
      'OUT_FOR_DELIVERY' => (
        AppColors.navy.withValues(alpha: 0.15),
        AppColors.navy,
        AppStrings.statusOnTheWay,
      ),
      'DELIVERED' => (
        AppColors.success.withValues(alpha: 0.15),
        AppColors.success,
        AppStrings.statusDeliveredBadge,
      ),
      'CANCELLED' => (
        AppColors.error.withValues(alpha: 0.15),
        AppColors.error,
        AppStrings.statusCancelled,
      ),
      // Unknown status — show it raw rather than hide it.
      _ => (
        AppColors.neutralGray.withValues(alpha: 0.15),
        AppColors.neutralGray,
        status,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: foreground,
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
    this.expanded = false,
  });

  final String label;
  final Color backgroundColor;
  final bool isLoading;
  final VoidCallback onTap;
  final String? leadingEmoji;
  final FontWeight fontWeight;

  /// When true the pill fills its parent's width and centers its content
  /// (e.g. the full-width "Pay Now" button).
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        alignment: expanded ? Alignment.center : null,
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
                mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
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
