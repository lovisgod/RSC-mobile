import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_event.dart';
import '../../domain/entities/order_history_entity.dart';
import '../../domain/usecases/reorder_usecase.dart';
import '../cubit/order_history_cubit.dart';

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({super.key, required this.order});

  final OrderHistoryEntity order;

  static const _deliveryModeColor = Color(0xFF2196F3);
  static const _reorderUseCase = ReorderUseCase();

  void _handleCardTap(BuildContext context) {
    if (order.isCompleted) {
      context.read<OrderHistoryCubit>().loadOrderDetail(order.id);
      context.push(RouteNames.orderDetails, extra: order.id);
    } else {
      context.read<ShellBloc>().add(const ShellTabChanged(3));
    }
  }

  Future<void> _handleReorder(BuildContext context) async {
    final cart = await _reorderUseCase.call(order);
    if (!context.mounted) return;
    context.push(RouteNames.checkout, extra: {'cart': cart});
  }

  @override
  Widget build(BuildContext context) {
    final moreCount = order.additionalItemsCount;

    return GestureDetector(
      onTap: () => _handleCardTap(context),
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

            // ── Bottom row: grand total + re-order ─────────────────────────
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
                GestureDetector(
                  onTap: () => _handleReorder(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      AppStrings.reorder,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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
