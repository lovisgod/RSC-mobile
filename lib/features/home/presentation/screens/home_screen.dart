import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../../../profile/presentation/cubit/address_cubit.dart';
import '../../../profile/presentation/cubit/address_state.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_state.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/outlet_card.dart';
import '../widgets/promo_banner_carousel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddressCubit>(
      create: (_) => getIt<AddressCubit>()..loadAddresses(),
      child: Scaffold(
        backgroundColor: AppColors.navyDark,
        body: Column(
          children: [
            // ── Navy header ──────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    const Expanded(child: _DeliveringToSection()),
                    const _NotificationBellButton(),
                    const SizedBox(width: 8),
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
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async {
                    final bloc = context.read<HomeBloc>();
                    final future = bloc.stream.firstWhere(
                      (state) => state is HomeLoaded || state is HomeError,
                    );
                    bloc.add(const HomeFetchRequested());
                    await future;
                  },
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return _ShimmerBody();
                      }
                      if (state is HomeError) {
                        return _ErrorBody(
                          message: state.message,
                          onRetry: () => context.read<HomeBloc>().add(
                            const HomeFetchRequested(),
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── Delivering-to section ────────────────────────────────────────────────────

class _DeliveringToSection extends StatelessWidget {
  const _DeliveringToSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellBloc, ShellState>(
      builder: (context, shellState) {
        if (!shellState.isAuthenticated) {
          return const _DeliveringToContent(
            bottomText: AppStrings.deliveryAddress,
            bottomColor: AppColors.textOnDark,
          );
        }

        return BlocBuilder<AddressCubit, AddressState>(
          builder: (context, addressState) {
            if (addressState.isLoading) {
              return const _DeliveringToShimmer();
            }

            final defaultAddress = addressState.defaultAddress;
            final hasDefault = defaultAddress != null;

            return _DeliveringToContent(
              bottomText: hasDefault
                  ? defaultAddress.addressLine
                  : AppStrings.addDeliveryAddress,
              bottomColor: hasDefault
                  ? AppColors.textOnDark
                  : AppColors.primary,
              chevronColor: hasDefault
                  ? AppColors.textOnDark
                  : AppColors.primary,
              onTap: () => context.push(RouteNames.manageAddresses).then((_) {
                if (context.mounted) {
                  context.read<AddressCubit>().loadAddresses();
                }
              }),
            );
          },
        );
      },
    );
  }
}

class _DeliveringToContent extends StatelessWidget {
  const _DeliveringToContent({
    required this.bottomText,
    required this.bottomColor,
    this.chevronColor,
    this.onTap,
  });

  final String bottomText;
  final Color bottomColor;
  final Color? chevronColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.deliveringTo,
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Flexible(
              child: Text(
                bottomText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: bottomColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (chevronColor != null)
              Text(
                '›',
                style: TextStyle(
                  color: chevronColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ],
    );

    if (onTap == null) return column;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: column,
    );
  }
}

class _DeliveringToShimmer extends StatelessWidget {
  const _DeliveringToShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.deliveringTo,
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 5),
        const ShimmerBox(height: 14, width: 140, radius: 4),
      ],
    );
  }
}

// ── Notification bell ────────────────────────────────────────────────────────

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.notifications),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Center(
              child: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                final unreadCount = state.unreadCount;
                if (unreadCount == 0) return const SizedBox.shrink();
                return Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar button ────────────────────────────────────────────────────────────

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state.userProfile;
        if (profile == null) {
          return Image.asset(AppAssets.iconProfile, width: 40, height: 40);
        }
        return ProfileAvatar(
          initials: profile.initials,
          avatarUrl: profile.avatarUrl,
          size: 40,
        );
      },
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
        BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, notifState) {
            return PromoBannerCarousel(notifications: notifState.notifications);
          },
        ),
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
              onTap: () => context.push('/outlet/${outlet.id}', extra: outlet),
            ),
          );
        }),
      ],
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
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
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
