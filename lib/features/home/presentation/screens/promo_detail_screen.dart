import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/rsc_image.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../domain/entities/promo_offer.dart';
import '../../domain/repositories/home_repository.dart';

/// Destination for tapping any promo card. `promo.deepLink` isn't defined on
/// the backend yet (always null in practice) — once it is, this screen
/// becomes the fallback for when a deepLink can't be resolved rather than
/// the only destination.
class PromoDetailScreen extends StatefulWidget {
  const PromoDetailScreen({super.key, required this.promo});

  final PromoOffer promo;

  @override
  State<PromoDetailScreen> createState() => _PromoDetailScreenState();
}

class _PromoDetailScreenState extends State<PromoDetailScreen> {
  Outlet? _outlet;
  bool _resolvingOutlet = false;

  @override
  void initState() {
    super.initState();
    if (widget.promo.isOutletScoped) _resolveOutlet();
  }

  Future<void> _resolveOutlet() async {
    setState(() => _resolvingOutlet = true);
    final outlets = await getIt<HomeRepository>().getOutlets();
    if (!mounted) return;
    setState(() {
      _outlet = outlets.firstWhereOrNull((o) => o.id == widget.promo.outletId);
      _resolvingOutlet = false;
    });
  }

  Future<void> _copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.promo.code));
    if (!context.mounted) return;
    AppSnackbar.show(
      context,
      message: AppStrings.promoCodeCopied,
      type: AppSnackbarType.success,
    );
  }

  void _onPrimaryAction(BuildContext context) {
    final outlet = _outlet;
    if (outlet != null) {
      context.push(RouteNames.outletDetailPath(outlet.id), extra: outlet);
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final promo = widget.promo;
    final now = DateTime.now();
    final hasExpired = promo.endsAt != null && now.isAfter(promo.endsAt!);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _Header(promo: promo, onBack: () => context.pop()),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${promo.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    promo.body,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (hasExpired) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        AppStrings.promoExpired,
                        style: TextStyle(fontSize: 13, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Promo code
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.rscPanel,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          AppStrings.promoCode,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              promo.code,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _copyCode(context),
                              icon: const Icon(Icons.copy_rounded),
                              color: AppColors.primary,
                              iconSize: 20,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Validity
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    label: promo.endsAt != null
                        ? '${AppStrings.validUntilPrefix}${formatDateTime(promo.endsAt!)}'
                        : AppStrings.validAtAllOutlets,
                  ),
                  if (promo.startsAt != null && now.isBefore(promo.startsAt!))
                    _InfoRow(
                      icon: Icons.event_available_rounded,
                      label:
                          '${AppStrings.validFromPrefix}${formatDateTime(promo.startsAt!)}',
                    ),
                  _InfoRow(
                    icon: Icons.storefront_outlined,
                    label: _resolvingOutlet
                        ? '…'
                        : (promo.isOutletScoped
                              ? '${AppStrings.validAtOutletPrefix}${_outlet?.name ?? AppStrings.kitchenFallbackName}'
                              : AppStrings.validAtAllOutlets),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: AppButton(
              label: promo.isOutletScoped
                  ? AppStrings.orderNow
                  : AppStrings.browseOutlets,
              backgroundColor: AppColors.navy,
              isLoading: _resolvingOutlet,
              onPressed: () => _onPrimaryAction(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.promo, required this.onBack});

  final PromoOffer promo;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        children: [
          Positioned.fill(
            child: promo.imageUrl != null
                ? RscImage(
                    imageUrl: promo.imageUrl,
                    width: double.infinity,
                    height: 160,
                    fallback: const _BannerFallback(),
                  )
                : const _BannerFallback(),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.navyDark, AppColors.navy],
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Image.asset(AppAssets.imgConfetti, width: 72, height: 72),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
