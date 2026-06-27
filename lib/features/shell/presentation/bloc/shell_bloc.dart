import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'shell_event.dart';
import 'shell_state.dart';

class ShellBloc extends Bloc<ShellEvent, ShellState> {
  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _authSubscription;

  ShellBloc(this._authBloc) : super(ShellState.initial()) {
    on<ShellTabChanged>(_onTabChanged);
    on<ShellAuthStateChanged>(_onAuthStateChanged);

    _authSubscription = _authBloc.stream.listen(
      (authState) => add(ShellAuthStateChanged(authState)),
    );

    // Sync if auth state is already resolved (e.g. resumed session)
    final current = _authBloc.state;
    if (current is LoginSuccess ||
        current is AuthUnauthenticated ||
        current is LogoutSuccess) {
      add(ShellAuthStateChanged(current));
    }
  }

  void _onTabChanged(ShellTabChanged event, Emitter<ShellState> emit) {
    emit(state.copyWith(activeTabIndex: event.index));
  }

  void _onAuthStateChanged(
    ShellAuthStateChanged event,
    Emitter<ShellState> emit,
  ) {
    final authState = event.authState;
    if (authState is LoginSuccess) {
      emit(state.copyWith(
        isAuthenticated: true,
        userId: authState.user.id,
        activeTabIndex: 0,
      ));
    } else if (authState is AuthUnauthenticated) {
      emit(state.copyWith(
        isAuthenticated: false,
        clearUser: true,
        activeTabIndex: 4,
      ));
    } else if (authState is LogoutSuccess) {
      emit(state.copyWith(
        isAuthenticated: false,
        clearUser: true,
        activeTabIndex: 0,
      ));
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
