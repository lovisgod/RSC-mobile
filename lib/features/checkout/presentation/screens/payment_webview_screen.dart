import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/payment_cubit.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.reference,
  });

  final String checkoutUrl;
  final String reference;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  /// Moment redirects here once the hosted checkout completes. Never
  /// hardcoded inline — always read from this constant.
  static const String _momentRedirectBase = 'https://dev.rscdev.tech/tracking';

  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasClosed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[RSC Payment] WebView opened');
    debugPrint('[RSC Payment] checkoutUrl: ${widget.checkoutUrl}');
    debugPrint('[RSC Payment] reference: ${widget.reference}');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('[RSC Payment] Page loading: $url');
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('[RSC Payment] Page loaded: $url');
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('[RSC Payment] ❌ WebView error: $error');
          },
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final url = request.url;
    debugPrint('[RSC Payment] Navigating to: $url');
    if (url.startsWith(_momentRedirectBase)) {
      final urlReference =
          Uri.parse(url).queryParameters['reference'] ?? widget.reference;
      debugPrint('[RSC Payment] ✅ Redirect intercepted: $url');
      debugPrint('[RSC Payment] Extracted reference: $urlReference');
      _closeAndVerify(urlReference);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  void _closeAndVerify(String reference) {
    if (_hasClosed) return;
    _hasClosed = true;
    context.read<PaymentCubit>().verifyPaymentResult(reference);
    Navigator.of(context).pop();
  }

  void _onManualClose() {
    if (_hasClosed) return;
    _hasClosed = true;
    debugPrint('[RSC Payment] ⚠️ WebView closed manually by user');
    debugPrint('[RSC Payment] Verifying with reference: ${widget.reference}');
    context.read<PaymentCubit>().verifyPaymentResult(widget.reference);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        _onManualClose();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.navyDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            AppStrings.securePayment,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.9),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text(
                          AppStrings.loadingPaymentPage,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
