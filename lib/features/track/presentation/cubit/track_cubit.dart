import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import '../../domain/entities/active_order_entity.dart';
import '../../domain/entities/rider_summary.dart';
import '../../domain/entities/sub_order_summary.dart';
import '../../domain/enums/order_tracking_status.dart';
import '../../domain/utils/order_id_generator.dart';
import 'track_state.dart';

class TrackCubit extends Cubit<TrackState> {
  TrackCubit(this._orderHistoryCubit) : super(TrackState.empty());

  final OrderHistoryCubit _orderHistoryCubit;
  final List<Timer> _timers = [];

  void startOrderTracking(List<CartItemEntity> cartItems) {
    _cancelTimers();

    final orderId = OrderIdGenerator.generateOrderId();
    final deliveryCode = OrderIdGenerator.generateDeliveryCode();

    final grouped = <String, List<CartItemEntity>>{};
    for (final item in cartItems) {
      (grouped[item.outletId] ??= []).add(item);
    }
    final subOrders = grouped.entries.map((e) {
      final items = e.value;
      return SubOrderSummary(
        outletEmoji: items.first.outletEmoji,
        outletName: items.first.outletName,
        itemSummaries:
            items.map((i) => '${i.quantity}x ${i.itemNameSnapshot}').toList(),
        status: SubOrderStatus.pending,
      );
    }).toList();

    emit(TrackState(
      activeOrder: ActiveOrderEntity(
        orderId: orderId,
        deliveryCode: deliveryCode,
        status: OrderTrackingStatus.pending,
        subOrders: subOrders,
      ),
    ));

    _timers.add(Timer(const Duration(seconds: 8), () {
      if (isClosed) return;
      final o = state.activeOrder;
      if (o == null) return;
      emit(TrackState(
        activeOrder: o.copyWith(
          status: OrderTrackingStatus.preparing,
          estimatedMinutes: 5,
          subOrders: o.subOrders
              .map((s) => s.copyWith(status: SubOrderStatus.preparing))
              .toList(),
        ),
      ));
    }));

    _timers.add(Timer(const Duration(seconds: 16), () {
      if (isClosed) return;
      final o = state.activeOrder;
      if (o == null) return;
      emit(TrackState(
        activeOrder: o.copyWith(
          status: OrderTrackingStatus.ready,
          rider: const RiderSummary(
            name: 'Emeka Chukwu',
            rating: 4.95,
            partnerType: 'In-House Partner',
            activeStatus: RiderActiveStatus.assigned,
          ),
          subOrders: o.subOrders
              .map((s) => s.copyWith(status: SubOrderStatus.ready))
              .toList(),
        ),
      ));
    }));

    _timers.add(Timer(const Duration(seconds: 24), () {
      if (isClosed) return;
      final o = state.activeOrder;
      if (o == null) return;
      emit(TrackState(
        activeOrder: o.copyWith(
          status: OrderTrackingStatus.collected,
          rider: o.rider?.copyWith(activeStatus: RiderActiveStatus.pickedUp),
          subOrders: o.subOrders
              .map((s) => s.copyWith(status: SubOrderStatus.collected))
              .toList(),
        ),
      ));
    }));

    _timers.add(Timer(const Duration(seconds: 32), () {
      if (isClosed) return;
      final o = state.activeOrder;
      if (o == null) return;
      emit(TrackState(
        activeOrder: o.copyWith(
          status: OrderTrackingStatus.delivered,
          rider: o.rider?.copyWith(activeStatus: RiderActiveStatus.delivered),
        ),
      ));
      _orderHistoryCubit.markOrderCompleted(orderId);
    }));

    _timers.add(Timer(const Duration(seconds: 62), () {
      if (isClosed) return;
      emit(TrackState.empty());
    }));
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
