import 'dart:async';
import 'dart:developer' as developer;

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../constants/api_constants.dart';
import '../constants/app_strings.dart';
import '../di/injection.dart';
import '../router/route_names.dart';
import '../storage/local_storage.dart';
import '../theme/app_colors.dart';

/// Central handler for expired-session responses, replacing the five
/// duplicated "if (statusCode == 401) throw AuthException(sessionExpiredLogin)"
/// checks that used to live in each repository. Registered before
/// `_ErrorInterceptor` in DioClient so it sees the raw 401 first — it doesn't
/// consume the error (always calls `handler.next`), so every repository's
/// existing error mapping still runs afterwards for non-auth-endpoint 401s.
///
/// `getIt<CartCubit>()`/`getIt<AuthBloc>()` are resolved lazily inside
/// [_handleExpiry], not injected via the constructor, so this never forces
/// those singletons to build earlier than the app already needs them.
class SessionInterceptor extends Interceptor {
  SessionInterceptor({
    required this.cookieJar,
    required this.localStorage,
    required this.scaffoldMessengerKey,
    required this.router,
  });

  final PersistCookieJar cookieJar;
  final LocalStorage localStorage;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  final GoRouter router;

  bool _isHandlingExpiry = false;

  /// Endpoints where a 401 means something other than "the session expired":
  /// wrong password/OTP on these auth flows, or a logout call that's already
  /// failing gracefully on its own.
  static const List<String> _excludedPaths = [
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.verifyUser,
    ApiConstants.forgotPassword,
    ApiConstants.resetPassword,
    ApiConstants.resendVerificationCode,
    ApiConstants.changePassword,
    ApiConstants.logout,
    ApiConstants.verifyProfileChange,
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isExcluded = _excludedPaths.any((p) => path.contains(p));

    final isExpiredToken403 =
        statusCode == 403 && _looksLikeExpiredToken(err.response);

    if ((statusCode == 401 || isExpiredToken403) &&
        !isExcluded &&
        !_isHandlingExpiry) {
      _isHandlingExpiry = true;
      unawaited(_handleExpiry());
    }

    handler.next(err);
  }

  /// Some endpoints return 403 (rather than 401) for an expired/invalid
  /// token, e.g. `{"message":"Authentication token is expired or invalid"}`.
  /// A blanket `statusCode == 403` would also catch legitimate
  /// permission-denied responses, so this only matches when the body's
  /// message/errors mention both "token" and "expired"/"invalid".
  bool _looksLikeExpiredToken(Response? response) {
    final data = response?.data;
    if (data is! Map) return false;

    final candidates = <String>[
      if (data['message'] is String) data['message'] as String,
      if (data['data'] is Map && (data['data'] as Map)['errors'] is List)
        ...((data['data'] as Map)['errors'] as List).whereType<String>(),
    ];

    return candidates.any((message) {
      final lower = message.toLowerCase();
      return lower.contains('token') &&
          (lower.contains('expired') || lower.contains('invalid'));
    });
  }

  Future<void> _handleExpiry() async {
    // A 401 with no stored user is a guest hitting an authenticated endpoint,
    // not an expired session — nothing to clear, nothing to tell the user.
    final userId = await localStorage.getUserId();
    if (userId == null) {
      debugPrint(
        '[RSC] 401 received but no user session exists — '
        'skipping expiry handler',
      );
      _isHandlingExpiry = false;
      return;
    }

    try {
      try {
        await cookieJar.deleteAll();
      } catch (_) {}

      try {
        await localStorage.clearAll();
      } catch (_) {}

      try {
        getIt<CartCubit>().clearCart();
      } catch (_) {}

      // Emitting through AuthBloc (rather than poking ShellBloc directly)
      // keeps AuthBloc as the single source of truth — ShellBloc, and the
      // cart-clear/profile-reload in app.dart, already react to its stream.
      try {
        getIt<AuthBloc>().add(const SessionExpired());
      } catch (_) {}

      router.go(RouteNames.home);

      await Future.delayed(const Duration(milliseconds: 400));

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text(
            AppStrings.sessionExpired,
            style: TextStyle(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      developer.log(
        'Session expiry handling failed: $e',
        name: 'SessionInterceptor',
      );
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        _isHandlingExpiry = false;
      });
    }
  }
}
