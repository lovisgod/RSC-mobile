import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';

class PromoBannerCard extends StatelessWidget {
  const PromoBannerCard({super.key, required this.promo});

  final NotificationEntity promo;

  @override
  Widget build(BuildContext context) {
    final promoCode = promo.data['promoCode'] as String?;

    return GestureDetector(
      onTap: () => context.read<NotificationsCubit>().markAsRead(promo.id),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Confetti image on right
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Image.asset(
                AppAssets.imgConfetti,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            // Text on left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    promo.body,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  if (promoCode != null && promoCode.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏷️', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.useCode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            promoCode,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
