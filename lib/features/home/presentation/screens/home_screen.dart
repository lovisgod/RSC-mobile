import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/outlet_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDark,
      body: Column(
        children: [
          // ── Navy header ──────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.deliveringTo,
                          style: const TextStyle(
                            color: Color(0xFF8A9CC0),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          AppStrings.deliveryAddress,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _AvatarButton(),
                ],
              ),
            ),
          ),

          // ── White body ───────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading || state is HomeInitial) {
                    return _ShimmerBody();
                  }
                  if (state is HomeError) {
                    return _ErrorBody(
                      message: state.message,
                      onRetry: () =>
                          context.read<HomeBloc>().add(const HomeFetchRequested()),
                    );
                  }
                  if (state is HomeLoaded) {
                    return _LoadedBody(outlets: state.outlets);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar button ────────────────────────────────────────────────────────────

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
    );
  }
}

// ── Loaded body ──────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.outlets});

  final List<Outlet> outlets;

  static const List<String> _emojis = ['🔥', '🍜', '🍲', '🍔', '🍽️'];
  static const List<Color> _colors = [
    AppColors.outletCardNavy,
    AppColors.outletCardGreen,
    AppColors.navyLight,
    AppColors.navyDark,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // ── Promo banner ────────────────────────────────────────────────
        _PromoBanner(),
        const SizedBox(height: 20),

        // ── Section heading ──────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppStrings.rscFoodKitchens,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Outlet cards ─────────────────────────────────────────────────
        ...outlets.asMap().entries.map((entry) {
          final index = entry.key;
          final outlet = entry.value;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: OutletCard(
              outlet: outlet,
              emoji: _emojis[index % _emojis.length],
              cardColor: _colors[index % _colors.length],
              onTap: () => context.push(
                '/outlet/${outlet.id}',
                extra: outlet,
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Promo banner ─────────────────────────────────────────────────────────────

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
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
              fit: BoxFit.contain,
            ),
          ),
          // Text on left
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            right: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🎉 ${AppStrings.freeDeliveryToday}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.freeDeliverySubtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _ShimmerBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Promo banner shimmer
        ShimmerBox(
          height: 80,
          radius: 14,
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        ),
        const SizedBox(height: 20),
        // Section heading shimmer
        const ShimmerBox(
          height: 18,
          width: 160,
          radius: 8,
          margin: EdgeInsets.symmetric(horizontal: 20),
        ),
        const SizedBox(height: 14),
        // Outlet card shimmers
        const ShimmerBox(
          height: 172,
          radius: 16,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
        ),
        const ShimmerBox(
          height: 172,
          radius: 16,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
        ),
        const ShimmerBox(
          height: 172,
          radius: 16,
          margin: EdgeInsets.fromLTRB(16, 0, 16, 12),
        ),
      ],
    );
  }
}

// ── Error body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 52,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.errorLoadingOutlets,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text(
                AppStrings.retry,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
