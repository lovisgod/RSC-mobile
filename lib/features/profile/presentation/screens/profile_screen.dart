import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/profile.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import '../cubit/order_history_cubit.dart';
import '../cubit/order_history_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/order_history_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AddressCubit _addressCubit;

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
    context.read<OrderHistoryCubit>().loadOrders();
    _addressCubit = getIt<AddressCubit>()..loadAddresses();
  }

  @override
  void dispose() {
    _addressCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _addressCubit,
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listenWhen: (prev, curr) =>
            (!prev.deactivated && curr.deactivated) ||
            (prev.isDeactivating && !curr.isDeactivating && curr.error != null),
        listener: (context, state) {
          if (state.deactivated) {
            // SessionExpired runs the same cleanup as logout: cookies +
            // storage here, cart clear + socket disconnect via the
            // LogoutSuccess listener in app.dart.
            context.read<AuthBloc>().add(const SessionExpired());
            context.go(RouteNames.auth);
            AppSnackbar.show(
              context,
              message: AppStrings.accountDeactivated,
              emoji: '',
              backgroundColor: AppColors.navy,
            );
          } else if (state.error != null) {
            AppSnackbar.show(
              context,
              message: state.error!,
              type: AppSnackbarType.error,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _ProfileHeader(state: state)),
                SliverToBoxAdapter(child: _LoggedInBody(state: state)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Profile header — always visible ──────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.userProfile;
    final showShimmer = state.isLoading && profile == null;

    return Container(
      color: AppColors.surfaceDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              // Avatar
              if (showShimmer)
                const ShimmerBox(height: 80, width: 80, radius: 40)
              else
                ProfileAvatar(
                  initials: profile?.initials ?? '',
                  avatarUrl: profile?.avatarUrl,
                ),
              const SizedBox(height: 14),

              // Name
              if (showShimmer)
                const ShimmerBox(height: 18, width: 140)
              else
                Text(
                  profile?.name ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnDark,
                  ),
                ),
              const SizedBox(height: 4),

              // Email
              if (showShimmer)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: ShimmerBox(height: 12, width: 180),
                )
              else
                Text(
                  profile?.email ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),

              // Phone
              const SizedBox(height: 2),
              if (showShimmer)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: ShimmerBox(height: 12, width: 120),
                )
              else
                Text(
                  profile?.displayPhone ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),

              // Edit Profile pill
              const SizedBox(height: 14),
              if (!showShimmer) _EditProfilePill(profile: profile),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfilePill extends StatelessWidget {
  const _EditProfilePill({required this.profile});

  final Profile? profile;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: profile == null
          ? null
          : () => context.push(RouteNames.editProfile, extra: profile),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✏️', style: TextStyle(fontSize: 14)),
            SizedBox(width: 6),
            Text(
              AppStrings.editProfile,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logged-in body ────────────────────────────────────────────────────────────

class _LoggedInBody extends StatelessWidget {
  const _LoggedInBody({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const _AddressCard(),
          const SizedBox(height: 8),
          const _ManageAddressesLink(),
          const SizedBox(height: 20),
          const _SecuritySection(),
          const SizedBox(height: 20),
          const _OrderHistorySection(),
          const SizedBox(height: 20),
          const _LogoutButton(),
          const SizedBox(height: 12),
          const _DeactivateAccountButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, addressState) {
        final defaultAddress = addressState.defaultAddress;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.defaultDeliveryAddress,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textLabel,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        defaultAddress?.displayAddress ??
                            AppStrings.noDefaultAddressSet,
                        style: TextStyle(
                          fontSize: 13,
                          color: defaultAddress != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () =>
                        context.push(RouteNames.manageAddresses).then((_) {
                          if (context.mounted) {
                            context.read<AddressCubit>().loadAddresses();
                          }
                        }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        defaultAddress != null
                            ? AppStrings.setDefault
                            : AppStrings.addAddress,
                        style: const TextStyle(
                          fontSize: 12,
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
        );
      },
    );
  }
}

class _ManageAddressesLink extends StatelessWidget {
  const _ManageAddressesLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RouteNames.manageAddresses).then((_) {
        if (context.mounted) {
          context.read<AddressCubit>().loadAddresses();
        }
      }),
      child: const Text(
        AppStrings.manageAddresses,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Security section ──────────────────────────────────────────────────────────

class _SecuritySection extends StatelessWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.security,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _SecurityRow(
                emoji: '🔒',
                label: AppStrings.changePassword,
                onTap: () => context.push(RouteNames.changePassword),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SecurityRow(
                emoji: '🔔',
                label: AppStrings.notificationSettings,
                onTap: () => context.push(RouteNames.notificationPreferences),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Order history section ─────────────────────────────────────────────────────

class _OrderHistorySection extends StatelessWidget {
  const _OrderHistorySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
      builder: (context, state) {
        final orders = state.orders;
        final preview = orders.take(4).toList();
        final showShimmer = state.isLoading && orders.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Text(
                  AppStrings.orderHistory,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push(RouteNames.orderHistory),
                  child: const Text(
                    AppStrings.seeAllOrders,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (showShimmer)
              Column(
                children: List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: ShimmerBox(
                      height: 140,
                      width: double.infinity,
                      radius: 14,
                    ),
                  ),
                ),
              )
            else if (orders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    AppStrings.noOrderHistory,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: preview
                    .map(
                      (o) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OrderHistoryCard(order: o),
                      ),
                    )
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}

// ── Logout ────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _showLogoutSheet(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          AppStrings.logOut,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  void _showLogoutSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: const _LogoutConfirmSheet(),
      ),
    );
  }
}

// ── Deactivate account ────────────────────────────────────────────────────────

class _DeactivateAccountButton extends StatelessWidget {
  const _DeactivateAccountButton();

  void _confirmDeactivation(BuildContext context) {
    final profileCubit = context.read<ProfileCubit>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deactivateConfirmTitle),
        content: const Text(AppStrings.deactivateConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              profileCubit.deactivateAccount();
            },
            child: const Text(
              AppStrings.deactivate,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Center(
          child: TextButton(
            onPressed: state.isDeactivating
                ? null
                : () => _confirmDeactivation(context),
            child: Text(
              AppStrings.deactivateAccount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.error.withValues(
                  alpha: state.isDeactivating ? 0.5 : 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoutConfirmSheet extends StatelessWidget {
  const _LogoutConfirmSheet();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, state) => state is LogoutSuccess,
      listener: (ctx, _) => Navigator.of(ctx).pop(),
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppStrings.logOutConfirmTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.logOutConfirmMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.divider),
                          shape: const StadiumBorder(),
                          minimumSize: const Size(0, 50),
                        ),
                        child: const Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: AppStrings.logOut,
                        backgroundColor: AppColors.error,
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const LogoutRequested(),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
