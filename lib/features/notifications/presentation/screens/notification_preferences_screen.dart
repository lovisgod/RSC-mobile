import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/notification_preferences_cubit.dart';
import '../cubit/notification_preferences_state.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationPreferencesCubit>().loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      NotificationPreferencesCubit,
      NotificationPreferencesState
    >(
      listenWhen: (previous, current) => previous.isSaving && !current.isSaving,
      listener: (context, state) {
        if (state.error != null) {
          AppSnackbar.show(
            context,
            message: state.error!,
            type: AppSnackbarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              const _AppBar(),
              BlocBuilder<
                NotificationPreferencesCubit,
                NotificationPreferencesState
              >(
                builder: (context, state) {
                  if (!state.isSaving) return const SizedBox.shrink();
                  return const LinearProgressIndicator(
                    color: AppColors.primary,
                    minHeight: 2,
                  );
                },
              ),
              Expanded(
                child:
                    BlocBuilder<
                      NotificationPreferencesCubit,
                      NotificationPreferencesState
                    >(
                      builder: (context, state) {
                        if (state.isLoading && state.preferences == null) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        }
                        return ListView(
                          padding: const EdgeInsets.only(bottom: 32),
                          children: const [_InfoCard(), _PreferencesCard()],
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.navyDark,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              AppStrings.notificationSettings,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF3FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ℹ️ ${AppStrings.aboutNotifications}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
            ),
          ),
          SizedBox(height: 6),
          Text(
            AppStrings.notificationInfoText,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Preferences card ───────────────────────────────────────────────────────────

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(16),
      ),
      child:
          BlocBuilder<
            NotificationPreferencesCubit,
            NotificationPreferencesState
          >(
            builder: (context, state) {
              final preferences = state.preferences;
              return Column(
                children: [
                  const _PreferenceTile(
                    emoji: '🛵',
                    iconBackground: AppColors.navy,
                    title: AppStrings.orderUpdates,
                    subtitle: AppStrings.orderUpdatesSubtitle,
                    value: true,
                    onChanged: null,
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _PreferenceTile(
                    emoji: '🎉',
                    iconBackground: AppColors.primary,
                    title: AppStrings.promotions,
                    subtitle: AppStrings.promotionsSubtitle,
                    value: preferences?.promotions ?? true,
                    onChanged: (val) => context
                        .read<NotificationPreferencesCubit>()
                        .updatePreference('promotions', val),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _PreferenceTile(
                    emoji: '💰',
                    iconBackground: AppColors.primary,
                    title: AppStrings.discounts,
                    subtitle: AppStrings.discountsSubtitle,
                    value: preferences?.discounts ?? true,
                    onChanged: (val) => context
                        .read<NotificationPreferencesCubit>()
                        .updatePreference('discounts', val),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _PreferenceTile(
                    emoji: '🌟',
                    iconBackground: AppColors.primary,
                    title: AppStrings.seasonalOffers,
                    subtitle: AppStrings.seasonalOffersSubtitle,
                    value: preferences?.seasonalOffers ?? true,
                    onChanged: (val) => context
                        .read<NotificationPreferencesCubit>()
                        .updatePreference('seasonalOffers', val),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.emoji,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String emoji;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onChanged == null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.navy,
            trackColor: isDisabled
                ? WidgetStateProperty.all(AppColors.navy.withValues(alpha: 0.3))
                : null,
            thumbColor: isDisabled
                ? WidgetStateProperty.all(AppColors.navy)
                : null,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
