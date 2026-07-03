import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../../profile/domain/entities/line_item_entity.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../domain/entities/rider_summary.dart';
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
    _pulseAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(_pulseController);
    context.read<TrackCubit>().loadActiveOrder();
  }

  @override
  void dispose() {
    _riderController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onStatusChanged(String? status) {
    switch (status) {
      case 'READY':
        _riderController.value = 0.0;
      case 'DISPATCHED':
        _riderController.forward(from: 0.0);
      case 'DELIVERED':
        _riderController.value = 1.0;
      default:
        _riderController.value = 0.0;
    }
  }

  Future<void> _onRefresh() => context.read<TrackCubit>().manualRefresh();

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    return BlocConsumer<TrackCubit, TrackState>(
      listenWhen: (prev, curr) =>
          prev.activeOrder?.status != curr.activeOrder?.status,
      listener: (_, state) => _onStatusChanged(state.activeOrder?.status),
      builder: (context, state) {
        final order = state.activeOrder;
        final orderIdDisplay = order?.displayOrderId ?? AppStrings.noOrderId;

        Widget body;
        if (state.hasActiveOrder && order != null) {
          body = _ActiveOrderBody(
            order: order,
            outlets: state.outlets,
            lastRefreshedAt: state.lastRefreshedAt,
            riderController: _riderController,
            pulseAnimation: _pulseAnimation,
          );
        } else if (state.isLoading) {
          body = const _LoadingBody();
        } else {
          body = const _NoActiveOrderBody();
        }

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
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children: [
                      // Thin refresh indicator when switching to a different
                      // order — the full shimmer is reserved for cold loads.
                      if (state.isLoading && state.hasActiveOrder)
                        const LinearProgressIndicator(
                          minHeight: 2,
                          color: AppColors.primary,
                          backgroundColor: Colors.transparent,
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: AppColors.primary,
                          child: body,
                        ),
                      ),
                    ],
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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
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
          ),
        ),
      ),
    );
  }
}

// ── Loading (shimmer) ─────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShimmerBox(height: 140, width: double.infinity, radius: 16),
              SizedBox(height: 16),
              ShimmerBox(height: 14, width: 140),
              SizedBox(height: 10),
              ShimmerBox(height: 90, width: double.infinity, radius: 12),
              SizedBox(height: 10),
              ShimmerBox(height: 90, width: double.infinity, radius: 12),
              SizedBox(height: 20),
              ShimmerBox(height: 130, width: double.infinity, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Active order body ─────────────────────────────────────────────────────────

class _ActiveOrderBody extends StatelessWidget {
  const _ActiveOrderBody({
    required this.order,
    required this.outlets,
    required this.lastRefreshedAt,
    required this.riderController,
    required this.pulseAnimation,
  });

  final OrderHistoryEntity order;
  final List<Outlet> outlets;
  final DateTime? lastRefreshedAt;
  final AnimationController riderController;
  final Animation<double> pulseAnimation;

  static const _riderStatuses = {'READY', 'DISPATCHED', 'DELIVERED'};
  static const _routeStatuses = {'DISPATCHED', 'DELIVERED'};

  @override
  Widget build(BuildContext context) {
    final hasRider = _riderStatuses.contains(order.status);
    final showRoute = _routeStatuses.contains(order.status);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EtaCard(
            order: order,
            pulseAnimation: pulseAnimation,
            lastRefreshedAt: lastRefreshedAt,
          ),
          const SizedBox(height: 16),

          // Rider route widget — animated in when dispatched.
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
            child: showRoute
                ? AnimatedBuilder(
                    key: const ValueKey('route'),
                    animation: riderController,
                    builder: (_, child) =>
                        RiderRouteWidget(progress: riderController.value),
                  )
                : const SizedBox(key: ValueKey('no-route')),
          ),

          _KitchenBreakdowns(order: order, outlets: outlets),

          const SizedBox(height: 6),
          _DeliveryHandoffCard(code: order.deliveryCode),

          if (hasRider) ...[
            const SizedBox(height: 24),
            _RiderSection(rider: _mockRiderFor(order.status)),
          ],
        ],
      ),
    );
  }
}

// TODO: Replace with real rider data once the backend populates
// latestRiderLocation on the order — there is no rider entity on the API yet.
RiderSummary _mockRiderFor(String status) {
  final activeStatus = switch (status) {
    'DISPATCHED' => RiderActiveStatus.pickedUp,
    'DELIVERED' => RiderActiveStatus.delivered,
    _ => RiderActiveStatus.assigned,
  };
  return RiderSummary(
    name: 'Emeka Chukwu',
    rating: 4.95,
    partnerType: 'In-House Partner',
    activeStatus: activeStatus,
  );
}

// ── ETA Card ──────────────────────────────────────────────────────────────────

class _EtaCard extends StatelessWidget {
  const _EtaCard({
    required this.order,
    required this.pulseAnimation,
    required this.lastRefreshedAt,
  });

  final OrderHistoryEntity order;
  final Animation<double> pulseAnimation;
  final DateTime? lastRefreshedAt;

  String get _lastRefreshedLabel {
    final at = lastRefreshedAt;
    if (at == null) return '';
    final mins = DateTime.now().difference(at).inMinutes;
    return mins < 1
        ? AppStrings.updatedJustNow
        : AppStrings.updatedMinsAgo(mins);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FB),
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
          _EtaMainText(status: order.status, pulseAnimation: pulseAnimation),
          const SizedBox(height: 4),
          _EtaSubtitle(status: order.status),
          if (lastRefreshedAt != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _lastRefreshedLabel,
                style: const TextStyle(fontSize: 10, color: AppColors.textHint),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EtaMainText extends StatelessWidget {
  const _EtaMainText({required this.status, required this.pulseAnimation});

  final String status;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    const mainStyle = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1.1,
    );
    const navyStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.navy,
      height: 1.1,
    );

    switch (status) {
      case 'READY':
        return const Text(AppStrings.etaReady, style: navyStyle);
      case 'DISPATCHED':
        return const Text(AppStrings.etaOnTheWay, style: navyStyle);
      case 'DELIVERED':
        return const Text(AppStrings.etaDelivered, style: navyStyle);
      default:
        return FadeTransition(
          opacity: pulseAnimation,
          child: const Text(AppStrings.etaProcessing, style: mainStyle),
        );
    }
  }
}

class _EtaSubtitle extends StatelessWidget {
  const _EtaSubtitle({required this.status});

  final String status;

  static const _style = TextStyle(fontSize: 13, color: AppColors.textSecondary);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'CONFIRMED':
      case 'PREPARING':
        return const Text(AppStrings.kitchenIsPreparingMeals, style: _style);
      case 'READY':
        return const Text(AppStrings.orderReady, style: _style);
      case 'DISPATCHED':
        return const Text(AppStrings.riderOnTheWay, style: _style);
      case 'DELIVERED':
        return Image.asset(AppAssets.imgConfetti, height: 32);
      default:
        return const Text(AppStrings.waitingForKitchen, style: _style);
    }
  }
}

// ── Kitchen breakdowns ────────────────────────────────────────────────────────

class _KitchenBreakdowns extends StatelessWidget {
  const _KitchenBreakdowns({required this.order, required this.outlets});

  final OrderHistoryEntity order;
  final List<Outlet> outlets;

  @override
  Widget build(BuildContext context) {
    final byOutlet = <String, List<LineItemEntity>>{};
    for (final item in order.lineItems) {
      (byOutlet[item.outletId] ??= []).add(item);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ...byOutlet.entries.map((entry) {
          final outletName =
              outlets.firstWhereOrNull((o) => o.id == entry.key)?.name ??
              AppStrings.kitchenFallbackName;
          final subOrderStatus = order.subOrders
              .firstWhereOrNull((s) => s.outletId == entry.key)
              ?.status;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _KitchenCard(
              outletName: outletName,
              items: entry.value,
              subOrderStatus: subOrderStatus,
            ),
          );
        }),
      ],
    );
  }
}

class _KitchenCard extends StatelessWidget {
  const _KitchenCard({
    required this.outletName,
    required this.items,
    required this.subOrderStatus,
  });

  final String outletName;
  final List<LineItemEntity> items;
  final String? subOrderStatus;

  // Outlets don't carry an emoji from the backend yet, so every kitchen card
  // uses the same generic fallback icon.
  static const _fallbackEmoji = '🍽️';

  Color get _badgeColor {
    switch (subOrderStatus) {
      case 'ACCEPTED':
        return AppColors.info;
      case 'PREPARING':
        return AppColors.primary;
      case 'READY':
        return AppColors.success;
      case 'COLLECTED':
      case 'DISPATCHED':
        return AppColors.navy;
      default:
        return AppColors.neutralGray;
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
                '$_fallbackEmoji $outletName',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (subOrderStatus != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    subOrderStatus!,
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
          ...items.map(
            (item) => Text(
              '${item.quantity}x ${item.itemNameSnapshot}',
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
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(radius),
        ),
      );

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
