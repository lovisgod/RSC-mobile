import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../profile/presentation/cubit/address_cubit.dart';
import '../../../profile/presentation/cubit/address_state.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/presentation/widgets/logout_confirm_sheet.dart';
import '../bloc/shell_bloc.dart';
import '../bloc/shell_event.dart';
import '../bloc/shell_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.rscSidebarBg,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DrawerProfileHeader(),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _DrawerAddressSection(),
            ),
            const Divider(color: AppColors.rscLine, height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  _DrawerLinkTile(
                    emoji: '🧾',
                    label: AppStrings.orderHistory,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.orderHistory);
                    },
                  ),
                  _DrawerLinkTile(
                    emoji: '📍',
                    label: AppStrings.deliveryAddresses,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.manageAddresses);
                    },
                  ),
                  _DrawerLinkTile(
                    emoji: '🔔',
                    label: AppStrings.notifications,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.notifications);
                    },
                  ),
                  _DrawerLinkTile(
                    emoji: '⚙️',
                    label: AppStrings.settings,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.notificationPreferences);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.rscLine, height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: _DrawerLogoutTile(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile summary header ──────────────────────────────────────────────────

class _DrawerProfileHeader extends StatelessWidget {
  const _DrawerProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellBloc, ShellState>(
      builder: (context, shellState) {
        if (!shellState.isAuthenticated) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                context.read<ShellBloc>().add(const ShellTabChanged(4));
              },
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.rscLine,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.rscSidebarInk,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.guestGreeting,
                          style: TextStyle(
                            color: AppColors.rscSidebarInk,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppStrings.drawerSignInPrompt,
                          style: TextStyle(
                            color: AppColors.rscSidebarMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, profileState) {
            final profile = profileState.userProfile;
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  if (profile == null)
                    const ShimmerBox(height: 56, width: 56, radius: 28)
                  else
                    ProfileAvatar(
                      initials: profile.initials,
                      avatarUrl: profile.avatarUrl,
                      size: 56,
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile?.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.rscSidebarInk,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile?.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.rscSidebarMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Delivery address section (moved from home_screen.dart) ─────────────────

class _DrawerAddressSection extends StatelessWidget {
  const _DrawerAddressSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellBloc, ShellState>(
      builder: (context, shellState) {
        if (!shellState.isAuthenticated) {
          return const _DrawerAddressContent(
            bottomText: AppStrings.deliveryAddress,
            bottomColor: AppColors.rscSidebarInk,
          );
        }

        return BlocBuilder<AddressCubit, AddressState>(
          builder: (context, addressState) {
            if (addressState.isLoading) {
              return const _DrawerAddressShimmer();
            }

            final defaultAddress = addressState.defaultAddress;
            final hasDefault = defaultAddress != null;

            return _DrawerAddressContent(
              bottomText: hasDefault
                  ? defaultAddress.addressLine
                  : AppStrings.addDeliveryAddress,
              bottomColor: hasDefault
                  ? AppColors.rscSidebarInk
                  : AppColors.rscBrand,
              chevronColor: hasDefault
                  ? AppColors.rscSidebarInk
                  : AppColors.rscBrand,
              onTap: () {
                Navigator.of(context).pop();
                context.push(RouteNames.manageAddresses).then((_) {
                  if (context.mounted) {
                    context.read<AddressCubit>().loadAddresses();
                  }
                });
              },
            );
          },
        );
      },
    );
  }
}

class _DrawerAddressContent extends StatelessWidget {
  const _DrawerAddressContent({
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
        Text(
          AppStrings.deliveringTo,
          style: TextStyle(
            color: AppColors.rscSidebarMuted,
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

class _DrawerAddressShimmer extends StatelessWidget {
  const _DrawerAddressShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.deliveringTo,
          style: TextStyle(
            color: AppColors.rscSidebarMuted,
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

// ── Link tile ────────────────────────────────────────────────────────────────

class _DrawerLinkTile extends StatelessWidget {
  const _DrawerLinkTile({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.rscSidebarInk,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.rscSidebarMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logout ────────────────────────────────────────────────────────────────────

class _DrawerLogoutTile extends StatelessWidget {
  const _DrawerLogoutTile();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () => showLogoutConfirmSheet(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rscDanger,
          side: const BorderSide(color: AppColors.rscDanger),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          AppStrings.logOut,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.rscDanger,
          ),
        ),
      ),
    );
  }
}
