import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_event.dart';
import '../../domain/entities/line_item_entity.dart';
import '../../domain/entities/order_history_entity.dart';
import '../../domain/usecases/reorder_usecase.dart';
import '../cubit/order_history_cubit.dart';
import '../cubit/order_history_state.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<Outlet> _outlets = const [];
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryCubit>().loadOrderDetail(widget.orderId);
    getIt<HomeRepository>().getOutlets().then((outlets) {
      if (mounted) setState(() => _outlets = outlets);
    });
  }

  String _outletName(String outletId) =>
      _outlets.firstWhereOrNull((o) => o.id == outletId)?.name ??
      AppStrings.kitchenFallbackName;

  Future<void> _handleReorder(OrderHistoryEntity order) async {
    if (_isReordering) return;
    setState(() => _isReordering = true);

    try {
      await getIt<ReorderUseCase>().call(order);
      if (!mounted) return;
      context.go(RouteNames.home);
      context.read<ShellBloc>().add(const ShellTabChanged(2));
      AppSnackbar.show(
        context,
        message: AppStrings.itemsAddedToCart,
        emoji: '',
        backgroundColor: AppColors.navy,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isReordering = false);
      AppSnackbar.show(
        context,
        message: AppStrings.reorderFailed,
        type: AppSnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(
              child: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
                builder: (context, state) {
                  final order = state.selectedOrder;
                  if (state.isLoadingDetail ||
                      order == null ||
                      order.id != widget.orderId) {
                    return const _DetailShimmer();
                  }
                  return _OrderDetailsBody(
                    order: order,
                    outletName: _outletName,
                    onReorder: () => _handleReorder(order),
                    isReordering: _isReordering,
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

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
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
            AppStrings.orderDetails,
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

// ── Loading shimmer ────────────────────────────────────────────────────────────

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 96, width: double.infinity, radius: 16),
          SizedBox(height: 20),
          ShimmerBox(height: 14, width: 120),
          SizedBox(height: 8),
          ShimmerBox(height: 120, width: double.infinity, radius: 12),
          SizedBox(height: 20),
          ShimmerBox(height: 160, width: double.infinity, radius: 12),
        ],
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({
    required this.order,
    required this.outletName,
    required this.onReorder,
    required this.isReordering,
  });

  final OrderHistoryEntity order;
  final String Function(String outletId) outletName;
  final VoidCallback onReorder;
  final bool isReordering;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<LineItemEntity>>{};
    for (final item in order.lineItems) {
      (grouped[item.outletId] ??= []).add(item);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderIdCard(order: order),
          const SizedBox(height: 20),

          if (order.deliveryMode == 'DELIVERY' &&
              order.deliveryAddress.isNotEmpty) ...[
            _SectionHeader(label: AppStrings.sectionDeliveryAddress),
            const SizedBox(height: 8),
            _AddressCard(address: order.deliveryAddress),
            const SizedBox(height: 20),
          ],

          _SectionHeader(label: AppStrings.itemsOrdered),
          const SizedBox(height: 8),
          ...grouped.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OutletGroupCard(
                outletName: outletName(entry.key),
                items: entry.value,
              ),
            ),
          ),
          const SizedBox(height: 8),

          _PriceBreakdownCard(order: order),
          const SizedBox(height: 24),

          AppButton(
            label: AppStrings.reorderEntireOrder,
            backgroundColor: AppColors.navy,
            isLoading: isReordering,
            onPressed: onReorder,
          ),
        ],
      ),
    );
  }
}

// ── Order ID card ─────────────────────────────────────────────────────────────

class _OrderIdCard extends StatelessWidget {
  const _OrderIdCard({required this.order});
  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            AppStrings.orderIdLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.displayOrderId,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          if (order.isCompleted)
            const Text(
              AppStrings.deliveredAndComplete,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                order.status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Address card ──────────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        address,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }
}

// ── Outlet group card ─────────────────────────────────────────────────────────

class _OutletGroupCard extends StatelessWidget {
  const _OutletGroupCard({required this.outletName, required this.items});

  final String outletName;
  final List<LineItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$outletName${AppStrings.subOrderSuffix}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => _LineItemRow(item: item)),
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.item});
  final LineItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.quantity}x ${item.itemNameSnapshot}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                formatNaira(item.lineTotal),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (item.modifiers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '+ ${item.modifiers.map((m) => m.name).join(', ')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Price breakdown card ──────────────────────────────────────────────────────

class _PriceBreakdownCard extends StatelessWidget {
  const _PriceBreakdownCard({required this.order});
  final OrderHistoryEntity order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: AppStrings.subtotal,
            value: formatNaira(order.subtotal),
          ),
          const SizedBox(height: 6),
          _PriceRow(
            label: AppStrings.deliveryFeeLabel,
            value: formatNaira(order.deliveryFee),
          ),
          const SizedBox(height: 6),
          _PriceRow(label: AppStrings.vatLabel, value: formatNaira(order.vat)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _PriceRow(
            label: AppStrings.grandTotal,
            value: formatNaira(order.total),
            isBold: true,
            valueColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 15 : 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(
          value,
          style: style.copyWith(color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}
