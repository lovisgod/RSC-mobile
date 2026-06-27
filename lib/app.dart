import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/profile/presentation/cubit/order_history_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/shell/presentation/bloc/shell_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ShellBloc>(
          create: (_) => getIt<ShellBloc>(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => getIt<CartCubit>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => getIt<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<OrderHistoryCubit>(
          create: (_) => getIt<OrderHistoryCubit>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (_, state) => state is LogoutSuccess || state is LoginSuccess,
        listener: (context, state) {
          if (state is LogoutSuccess) {
            context.read<CartCubit>().clearCart();
          }
          context.read<ProfileCubit>().loadProfile();
        },
        child: MaterialApp.router(
          title: 'RSC',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
