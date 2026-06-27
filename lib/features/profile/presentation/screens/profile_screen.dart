import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/order_history_cubit.dart';
import '../cubit/order_history_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import '../widgets/order_history_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
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
    );
  }
}

// ── Profile header — always visible ──────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    state.userInitials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Name
              Text(
                state.userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnDark,
                ),
              ),
              const SizedBox(height: 4),

              // Email
              Text(
                state.userEmail,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),

              // Phone
              const SizedBox(height: 2),
              Text(
                state.userPhone,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),

              // Edit Profile pill
              const SizedBox(height: 14),
              _EditProfilePill(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfilePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppSnackbar.show(
        context,
        message: AppStrings.comingSoon,
        emoji: '🛠️',
        type: AppSnackbarType.info,
      ),
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
          _AddressCard(address: state.defaultAddress),
          const SizedBox(height: 20),
          const _SecuritySection(),
          const SizedBox(height: 20),
          const _OrderHistorySection(),
          const SizedBox(height: 20),
          const _LogoutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
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
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => AppSnackbar.show(
                  context,
                  message: AppStrings.comingSoon,
                  emoji: '🛠️',
                  type: AppSnackbarType.info,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    AppStrings.setDefault,
                    style: TextStyle(
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
        GestureDetector(
          onTap: () => context.push(RouteNames.changePassword),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Text('🔒', style: TextStyle(fontSize: 18)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.changePassword,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textHint,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
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
        final hasMore = orders.length > 4;

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
                if (hasMore)
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

            if (orders.isEmpty)
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
                            : () => context
                                .read<AuthBloc>()
                                .add(const LogoutRequested()),
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
