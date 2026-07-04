import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/order_event_entity.dart';

/// Vertical timeline of [OrderEventEntity]s, newest first (caller is expected
/// to have already sorted them — see TrackCubit._sortedEvents).
class OrderTimelineWidget extends StatelessWidget {
  const OrderTimelineWidget({super.key, required this.events});

  final List<OrderEventEntity> events;

  static Color _badgeColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return AppColors.info;
      case 'PARTIALLY_READY':
        return AppColors.warning;
      case 'READY':
      case 'DELIVERED':
        return AppColors.success;
      case 'OUT_FOR_DELIVERY':
        return AppColors.navy;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.neutralGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _TimelineRow(
            event: events[i],
            isMostRecent: i == 0,
            isLast: i == events.length - 1,
            badgeColor: _badgeColor(events[i].masterStatus),
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isMostRecent,
    required this.isLast,
    required this.badgeColor,
  });

  final OrderEventEntity event;
  final bool isMostRecent;
  final bool isLast;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isMostRecent
                      ? AppColors.primary
                      : AppColors.neutralGray,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: AppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            event.masterStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        if (event.note.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            event.note,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    formatTime(event.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
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
