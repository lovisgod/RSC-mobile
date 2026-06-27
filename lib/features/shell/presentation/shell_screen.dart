import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection.dart';
import '../../../core/mock/mock_user.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../auth/presentation/screens/auth_flow_screen.dart';
import '../../cart/presentation/screens/cart_screen.dart';
import '../../home/presentation/bloc/home_bloc.dart';
import '../../home/presentation/bloc/home_event.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../profile/presentation/screens/profile_screen.dart';
import '../../search/presentation/bloc/search_bloc.dart';
import '../../search/presentation/screens/search_screen.dart';
import '../../track/presentation/cubit/track_cubit.dart';
import '../../track/presentation/screens/track_screen.dart';
import 'bloc/shell_bloc.dart';
import 'bloc/shell_event.dart';
import 'bloc/shell_state.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShellBloc, ShellState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: IndexedStack(
            index: state.activeTabIndex,
            children: [
              BlocProvider(
                create: (_) =>
                    getIt<HomeBloc>()..add(const HomeFetchRequested()),
                child: const HomeScreen(),
              ),
              BlocProvider(
                create: (_) => getIt<SearchBloc>(),
                child: const SearchScreen(),
              ),
              const CartScreen(),
              BlocProvider.value(
                value: getIt<TrackCubit>(),
                child: const TrackScreen(),
              ),
              state.isAuthenticated
                  ? const ProfileScreen()
                  : const AuthFlowScreen(),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            activeIndex: state.activeTabIndex,
            isAuthenticated: state.isAuthenticated,
            userInitials:
                state.isAuthenticated ? MockUser.initials : null,
            onTabSelected: (index) =>
                context.read<ShellBloc>().add(ShellTabChanged(index)),
          ),
        );
      },
    );
  }
}
