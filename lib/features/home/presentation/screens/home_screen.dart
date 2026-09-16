import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/presentation/cubit/notifications_state.dart';
import '../../../profile/presentation/cubit/address_cubit.dart';
import '../../../search/presentation/bloc/search_bloc.dart';
import '../../../search/presentation/bloc/search_event.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_state.dart';
import '../../../shell/presentation/widgets/app_drawer.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/daily_specials_carousel.dart';
import '../widgets/outlet_card.dart';
import '../widgets/promo_banner_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SearchBloc _searchBloc;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _searchBloc = getIt<SearchBloc>();
    _searchFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _searchBloc.close();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_searchFocusNode.hasFocus && !_searchActive) {
      setState(() => _searchActive = true);
      _searchBloc.add(const SearchQueryChanged(''));
    }
  }

  void _onSearchChanged(String value) {
    if (!_searchActive) setState(() => _searchActive = true);
    _searchBloc.add(SearchQueryChanged(value));
  }

  void _onSearchCancel() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() => _searchActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddressCubit>(
      create: (_) => getIt<AddressCubit>()..loadAddresses(),
      child: BlocProvider<SearchBloc>.value(
        value: _searchBloc,
        child: Scaffold(
          backgroundColor: AppColors.surfaceDark,
          drawer: const AppDrawer(),
          body: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────
              SafeArea(bottom: false, child: _HomeHeader()),

              // ── Inline search bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: _InlineSearchField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  isActive: _searchActive,
                  onChanged: _onSearchChanged,
                  onCancel: _onSearchCancel,
                ),
              ),

              // ── White body ─────────────────────────────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: _searchActive
                      ? const SearchResultsView()
                      : RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          onRefresh: () async {
                            final bloc = context.read<HomeBloc>();
                            final future = bloc.stream.firstWhere(
                              (state) =>
                                  state is HomeLoaded || state is HomeError,
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
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.rscInk,
                size: 26,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                AppAssets.logo,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const _NotificationBellButton(),
        ],
      ),
    );
  }
}

// ── Inline search field ───────────────────────────────────────────────────────

class _InlineSearchField extends StatelessWidget {
  const _InlineSearchField({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onChanged,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.rscPanel,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: AppColors.rscInk),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hintText: AppStrings.searchAcrossAllOutlets,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.rscMuted,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    AppAssets.iconSearch,
                    width: 18,
                    height: 18,
                    color: AppColors.rscMuted,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        if (isActive) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onCancel,
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(
                color: AppColors.rscInk,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Notification bell ────────────────────────────────────────────────────────

class _NotificationBellButton extends StatelessWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellBloc, ShellState>(
      builder: (context, shellState) {
        // Guests have no notifications endpoint access — remove the bell
        // from the layout entirely so no badge or API call can happen.
        if (!shellState.isAuthenticated) return const SizedBox.shrink();

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
                    Icons.notifications,
                    color: AppColors.rscInk,
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
        // ── Daily specials ──────────────────────────────────────────────
        const DailySpecialsCarousel(),

        // ── Section heading ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  AppStrings.ourOutlets,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (outlets.isNotEmpty)
                GestureDetector(
                  onTap: () =>
                      context.push(RouteNames.outletList, extra: outlets),
                  child: const Text(
                    AppStrings.viewAll,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (outlets.isEmpty)
          const _EmptyOutletsState()
        else
          // ── Outlet cards ─────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: outlets.length,
              itemBuilder: (context, index) {
                final outlet = outlets[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 180,
                    child: OutletCard(
                      outlet: outlet,
                      emoji: _emojis[index % _emojis.length],
                      cardColor: _colors[index % _colors.length],
                      onTap: () =>
                          context.push('/outlet/${outlet.id}', extra: outlet),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),

        // ── Exclusive discounts ──────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Text('🏷️', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppStrings.exclusiveDiscounts,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                AppStrings.viewAll,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const PromoBannerCarousel(),
      ],
    );
  }
}

class _EmptyOutletsState extends StatelessWidget {
  const _EmptyOutletsState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.42,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.navActiveBackground,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppStrings.noOutletsAvailable,
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.noOutletsAvailableDescription,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
