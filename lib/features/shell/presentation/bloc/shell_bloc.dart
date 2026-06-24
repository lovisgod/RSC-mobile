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

    // Sync immediately if auth state is already known (resumed session)
    final current = _authBloc.state;
    if (current is AuthAuthenticated || current is AuthUnauthenticated) {
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
    if (event.authState is AuthAuthenticated) {
      final user = (event.authState as AuthAuthenticated).user;
      emit(state.copyWith(isAuthenticated: true, currentUser: user));
    } else if (event.authState is AuthUnauthenticated) {
      emit(state.copyWith(isAuthenticated: false, clearUser: true));
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
