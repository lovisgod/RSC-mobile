import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../auth/presentation/screens/auth_flow_screen.dart';
import '../../cart/presentation/screens/cart_placeholder_screen.dart';
import '../../home/presentation/screens/home_placeholder_screen.dart';
import '../../profile/presentation/screens/profile_placeholder_screen.dart';
import '../../search/presentation/screens/search_placeholder_screen.dart';
import '../../track/presentation/screens/track_placeholder_screen.dart';
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
              state.isAuthenticated
                  ? const HomePlaceholderScreen()
                  : const AuthFlowScreen(),
              const SearchPlaceholderScreen(),
              const CartPlaceholderScreen(),
              const TrackPlaceholderScreen(),
              const ProfilePlaceholderScreen(),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            activeIndex: state.activeTabIndex,
            isAuthenticated: state.isAuthenticated,
            userInitials: state.userInitials,
            onTabSelected: (index) =>
                context.read<ShellBloc>().add(ShellTabChanged(index)),
          ),
        );
      },
    );
  }
}
