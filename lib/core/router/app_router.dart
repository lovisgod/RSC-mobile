import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/screens/auth_flow_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/new_password_screen.dart';
import '../../features/auth/presentation/screens/reset_otp_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/cart/domain/entities/cart_entity.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/home/presentation/bloc/outlet_detail_bloc.dart';
import '../../features/home/presentation/bloc/outlet_detail_event.dart';
import '../../features/home/presentation/screens/item_detail_screen.dart';
import '../../features/home/presentation/screens/outlet_detail_screen.dart';
import '../../features/menu/domain/entities/menu_item.dart';
import '../../features/menu/domain/entities/outlet.dart';
import '../../features/notifications/presentation/cubit/notification_preferences_cubit.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/screens/notification_preferences_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/domain/entities/profile.dart';
import '../../features/profile/presentation/cubit/address_cubit.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/manage_addresses_screen.dart';
import '../../features/profile/presentation/screens/order_details_screen.dart';
import '../../features/profile/presentation/screens/order_history_screen.dart';
import '../../features/profile/presentation/screens/profile_verify_otp_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';
import '../di/injection.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: kDebugMode,
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),

    // ── Main shell — bottom nav always visible, IndexedStack inside ──────────
    GoRoute(
      path: '/',
      name: 'shell',
      builder: (context, state) => const ShellScreen(),
    ),

    // ── Outlet detail — full screen, no bottom nav ───────────────────────────
    GoRoute(
      path: '/outlet/:outletId',
      name: 'outletDetail',
      builder: (context, state) {
        final outlet = state.extra as Outlet;
        return BlocProvider(
          create: (_) =>
              getIt<OutletDetailBloc>()
                ..add(OutletDetailFetchRequested(outlet.id)),
          child: OutletDetailScreen(outlet: outlet),
        );
      },
    ),

    // ── Item detail — full screen, no bottom nav ─────────────────────────────
    GoRoute(
      path: '/outlet/:outletId/item/:itemId',
      name: 'itemDetail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final menuItem = extra['menuItem'] as MenuItem;
        final outlet = extra['outlet'] as Outlet;
        final fromSearch = extra['fromSearch'] as bool? ?? false;
        return ItemDetailScreen(
          menuItem: menuItem,
          outlet: outlet,
          fromSearch: fromSearch,
        );
      },
    ),

    // ── Auth flows — full-screen, no bottom nav ──────────────────────────────
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) {
        return BlocListener<AuthBloc, AuthState>(
          listenWhen: (_, s) => s is LoginSuccess,
          listener: (ctx, _) => ctx.pop(),
          child: const AuthFlowScreen(),
        );
      },
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OtpPage(phone: phone);
      },
    ),

    // ── Full-screen routes — no bottom nav ───────────────────────────────────
    GoRoute(
      path: '/checkout',
      name: 'checkout',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final cart = extra['cart'] as CartEntity;
        return CheckoutPage(cart: cart);
      },
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => BlocProvider.value(
        value: getIt<NotificationsCubit>(),
        child: const NotificationsScreen(),
      ),
    ),
    GoRoute(
      path: '/notification-preferences',
      name: 'notificationPreferences',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<NotificationPreferencesCubit>(),
        child: const NotificationPreferencesScreen(),
      ),
    ),
    // ── Password reset flow — full-screen, no bottom nav ─────────────────────
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-otp',
      name: 'resetOtp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ResetOtpScreen(
          identifier: extra['identifier'] as String,
          otpExpiresInSeconds: extra['otpExpiresInSeconds'] as int,
        );
      },
    ),
    GoRoute(
      path: '/new-password',
      name: 'newPassword',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return NewPasswordScreen(
          identifier: extra['identifier'] as String,
          otpCode: extra['otpCode'] as String,
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      name: 'changePassword',
      builder: (_, _) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/profile/orders',
      name: 'orderHistory',
      builder: (context, state) => const OrderHistoryScreen(),
    ),
    GoRoute(
      path: '/profile/orders/details',
      name: 'orderDetails',
      builder: (context, state) {
        final orderId = state.extra as String;
        return OrderDetailsScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'editProfile',
      builder: (context, state) {
        final profile = state.extra as Profile;
        return EditProfileScreen(profile: profile);
      },
    ),
    GoRoute(
      path: '/manage-addresses',
      name: 'manageAddresses',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => getIt<AddressCubit>(),
          child: const ManageAddressesScreen(),
        );
      },
    ),
    GoRoute(
      path: '/profile-verify-otp',
      name: 'profileVerifyOtp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ProfileVerifyOtpScreen(
          otpExpiresInSeconds: extra['otpExpiresInSeconds'] as int,
        );
      },
    ),
  ],
);
