import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/active_order_entity.dart';
import '../../domain/entities/rider_summary.dart';
import '../../domain/entities/sub_order_summary.dart';
import '../../domain/enums/order_tracking_status.dart';
import '../cubit/track_cubit.dart';
import '../cubit/track_state.dart';
import '../widgets/rider_route_widget.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with TickerProviderStateMixin {
  late final AnimationController _riderController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _riderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _riderController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStatusChanged(OrderTrackingStatus? status) {
    switch (status) {
      case OrderTrackingStatus.pending:
      case OrderTrackingStatus.preparing:
      case OrderTrackingStatus.ready:
        _riderController.value = 0.0;
      case OrderTrackingStatus.collected:
        _riderController.forward(from: 0.0);
      case OrderTrackingStatus.delivered:
        _riderController.value = 1.0;
      case null:
        _riderController.value = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return BlocConsumer<TrackCubit, TrackState>(
      listenWhen: (prev, curr) =>
          prev.activeOrder?.status != curr.activeOrder?.status,
      listener: (_, state) => _onStatusChanged(state.activeOrder?.status),
      builder: (context, state) {
        final order = state.activeOrder;
        final orderIdDisplay = order != null
            ? '#${order.orderId}'
            : AppStrings.noOrderId;

        return Scaffold(
          backgroundColor: AppColors.navyDark,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: statusBarHeight),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.orderProgress,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      orderIdDisplay,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: order == null
                      ? const _NoActiveOrderBody()
                      : _ActiveOrderBody(
                          order: order,
                          riderController: _riderController,
                          pulseAnimation: _pulseAnimation,
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── No active order ───────────────────────────────────────────────────────────

class _NoActiveOrderBody extends StatelessWidget {
  const _NoActiveOrderBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.iconTrack, width: 80, height: 80),
            const SizedBox(height: 24),
            const Text(
              AppStrings.noActiveOrders,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.browseKitchensToOrder,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active order body ─────────────────────────────────────────────────────────

class _ActiveOrderBody extends StatelessWidget {
  const _ActiveOrderBody({
    required this.order,
    required this.riderController,
    required this.pulseAnimation,
  });

  final ActiveOrderEntity order;
  final AnimationController riderController;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final hasRider = order.rider != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EtaCard(order: order, pulseAnimation: pulseAnimation),
          const SizedBox(height: 16),

          // Rider route widget — animated in when rider is assigned
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: hasRider
                ? AnimatedBuilder(
                    key: const ValueKey('route'),
                    animation: riderController,
                    builder: (_, child) => RiderRouteWidget(
                      progress: riderController.value,
                    ),
                  )
                : const SizedBox(key: ValueKey('no-route')),
          ),

          const Text(
            AppStrings.kitchenBreakdowns,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          ...order.subOrders.map((sub) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _KitchenCard(subOrder: sub),
              )),

          const SizedBox(height: 6),
          _DeliveryHandoffCard(code: order.deliveryCode),

          if (hasRider) ...[
            const SizedBox(height: 24),
            _RiderSection(rider: order.rider!),
          ],
        ],
      ),
    );
  }
}

// ── ETA Card ──────────────────────────────────────────────────────────────────

class _EtaCard extends StatelessWidget {
  const _EtaCard({required this.order, required this.pulseAnimation});

  final ActiveOrderEntity order;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            AppStrings.estimatedDeliveryTime,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          _EtaMainText(order: order, pulseAnimation: pulseAnimation),
          const SizedBox(height: 4),
          const Text(
            AppStrings.kitchenIsPreparingMeals,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EtaMainText extends StatelessWidget {
  const _EtaMainText({required this.order, required this.pulseAnimation});

  final ActiveOrderEntity order;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    const mainStyle = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.1,
    );

    switch (order.status) {
      case OrderTrackingStatus.pending:
        return const Text('---', style: mainStyle);
      case OrderTrackingStatus.preparing:
        return Text(
          '${order.estimatedMinutes} min',
          style: mainStyle,
        );
      case OrderTrackingStatus.ready:
      case OrderTrackingStatus.collected:
        return FadeTransition(
          opacity: pulseAnimation,
          child: const Text(AppStrings.etaProcessing, style: mainStyle),
        );
      case OrderTrackingStatus.delivered:
        return const Text(AppStrings.etaDelivered, style: mainStyle);
    }
  }
}

// ── Kitchen card ──────────────────────────────────────────────────────────────

class _KitchenCard extends StatelessWidget {
  const _KitchenCard({required this.subOrder});

  final SubOrderSummary subOrder;

  Color get _badgeColor {
    switch (subOrder.status) {
      case SubOrderStatus.pending:
      case SubOrderStatus.preparing:
        return AppColors.primary;
      case SubOrderStatus.ready:
        return AppColors.success;
      case SubOrderStatus.collected:
        return AppColors.navyDark;
    }
  }

  String get _badgeLabel {
    switch (subOrder.status) {
      case SubOrderStatus.pending:
        return 'PENDING';
      case SubOrderStatus.preparing:
        return 'PREPARING';
      case SubOrderStatus.ready:
        return 'READY';
      case SubOrderStatus.collected:
        return 'COLLECTED';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${subOrder.outletEmoji} ${subOrder.outletName}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _badgeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _badgeColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...subOrder.itemSummaries.map(
            (s) => Text(
              s,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delivery handoff code card ─────────────────────────────────────────────────

class _DeliveryHandoffCard extends StatelessWidget {
  const _DeliveryHandoffCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: AppColors.primary),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Text(
              AppStrings.deliveryHandoffCode,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              code,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              AppStrings.shareDeliveryCode,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    const radius = 12.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

// ── Rider section ─────────────────────────────────────────────────────────────

class _RiderSection extends StatelessWidget {
  const _RiderSection({required this.rider});

  final RiderSummary rider;

  String get _statusLabel {
    switch (rider.activeStatus) {
      case RiderActiveStatus.assigned:
        return AppStrings.riderStatusAssigned;
      case RiderActiveStatus.pickedUp:
        return AppStrings.riderStatusPickedUp;
      case RiderActiveStatus.delivered:
        return AppStrings.riderStatusDelivered;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏍️', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            rider.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '⭐ ${rider.rating} · ${rider.partnerType}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                const TextSpan(
                  text: AppStrings.riderActiveStatusPrefix,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextSpan(
                  text: _statusLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text('📞', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
