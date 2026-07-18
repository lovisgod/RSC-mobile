import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import 'promo_banner_card.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key, required this.notifications});

  final List<NotificationEntity> notifications;

  // Cast wide net for all promo types — add more here as backend adds them.
  static const _promoTypes = {'SPECIAL_PERIOD', 'PROMOTION', 'DISCOUNT'};

  List<NotificationEntity> get _promos =>
      notifications.where((n) => _promoTypes.contains(n.type)).toList();

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  static const _autoScrollInterval = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _maybeStartAutoScroll();
  }

  @override
  void didUpdateWidget(covariant PromoBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Notifications load asynchronously, so the promo count usually goes
    // from 0 → N after this widget has already mounted — restart the loop
    // against the fresh count whenever it changes.
    final promoCount = widget._promos.length;
    if (promoCount == oldWidget._promos.length) return;
    if (_currentPage >= promoCount) _currentPage = 0;
    _autoScrollTimer?.cancel();
    _maybeStartAutoScroll();
  }

  void _maybeStartAutoScroll() {
    final promoCount = widget._promos.length;
    if (promoCount <= 1) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!_pageController.hasClients) return;
      _currentPage = _currentPage < promoCount - 1 ? _currentPage + 1 : 0;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promos = widget._promos;
    if (promos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: _pageController,
              itemCount: promos.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) =>
                  PromoBannerCard(promo: promos[index]),
            ),
          ),
          if (promos.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: promos.length,
                effect: WormEffect(
                  dotHeight: 6,
                  dotWidth: 6,
                  activeDotColor: AppColors.surface,
                  dotColor: AppColors.surface.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
