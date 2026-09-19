import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/promo_offer.dart';
import '../../domain/repositories/promos_repository.dart';
import 'promo_banner_card.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final _repository = getIt<PromosRepository>();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  List<PromoOffer> _promos = const [];

  static const _autoScrollInterval = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final promos = await _repository.getActivePromos();
    if (!mounted) return;
    setState(() => _promos = promos);
    _maybeStartAutoScroll();
  }

  void _maybeStartAutoScroll() {
    final promoCount = _promos.length;
    if (promoCount <= 1) return;
    _autoScrollTimer?.cancel();
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
    if (_promos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            height: 136,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _promos.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) =>
                  PromoBannerCard(promo: _promos[index]),
            ),
          ),
          if (_promos.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _promos.length,
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
