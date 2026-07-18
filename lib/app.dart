import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/socket_service.dart';
import 'core/storage/local_storage.dart';
import 'core/theme/app_theme.dart';
import 'main.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/profile/domain/usecases/get_order_by_id_usecase.dart';
import 'features/profile/presentation/cubit/order_history_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/profile/presentation/cubit/rating_cubit.dart';
import 'features/profile/presentation/widgets/rate_order_bottom_sheet.dart';
import 'features/shell/presentation/bloc/shell_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  static const _ratingPromptDelay = Duration(minutes: 15);

  bool _isCheckingPendingRatings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cold start counts as a foreground too — a delivery may have completed
    // while the app was killed.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkPendingRatings(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkPendingRatings();
  }

  /// Shows at most ONE rating prompt per foreground, for the first pending
  /// order delivered ≥15 minutes ago. The pending marker is cleared as soon
  /// as the sheet is shown — skipping counts as handled.
  Future<void> _checkPendingRatings() async {
    if (_isCheckingPendingRatings) return;
    _isCheckingPendingRatings = true;
    try {
      final localStorage = getIt<LocalStorage>();
      final orderIds = await localStorage.getPendingRatingOrderIds();

      for (final orderId in orderIds) {
        final pending = await localStorage.getPendingRating(orderId);
        if (pending == null) {
          await localStorage.clearPendingRating(orderId);
          continue;
        }

        final minutesElapsed = DateTime.now()
            .difference(pending.deliveredAt)
            .inMinutes;
        if (minutesElapsed < _ratingPromptDelay.inMinutes) continue;

        await localStorage.clearPendingRating(orderId);

        final order = await getIt<GetOrderByIdUseCase>()(orderId);
        if (order.lineItems.isEmpty) continue;

        final context = navigatorKey.currentContext;
        if (context == null || !context.mounted) return;

        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: getIt<RatingCubit>(),
            child: RateOrderBottomSheet(
              lineItems: order.lineItems,
              orderId: orderId,
            ),
          ),
        );
        break;
      }
    } catch (e) {
      debugPrint('[RSC Rating] Pending rating check failed: $e');
    } finally {
      _isCheckingPendingRatings = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ShellBloc>(create: (_) => getIt<ShellBloc>()),
        BlocProvider<CartCubit>(create: (_) => getIt<CartCubit>()),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<OrderHistoryCubit>(
          create: (_) => getIt<OrderHistoryCubit>(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) => getIt<NotificationsCubit>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (_, state) =>
            state is LogoutSuccess || state is LoginSuccess,
        listener: (context, state) {
          if (state is LogoutSuccess) {
            context.read<CartCubit>().clearCart();
            getIt<SocketService>().disconnect();
            debugPrint('[RSC Socket] Disconnecting after logout');
          }
          context.read<ProfileCubit>().loadProfile();
          if (state is LoginSuccess) {
            context.read<NotificationsCubit>().loadNotifications();
            getIt<NotificationService>().refreshAndSaveToken();
            getIt<SocketService>().connect();
            debugPrint('[RSC Socket] Connecting after login');
          }
        },
        child: MaterialApp.router(
          title: 'RSC',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
