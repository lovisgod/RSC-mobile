import '../../../auth/presentation/bloc/auth_state.dart';

abstract class ShellEvent {
  const ShellEvent();
}

class ShellTabChanged extends ShellEvent {
  final int index;
  const ShellTabChanged(this.index);
}

class ShellAuthStateChanged extends ShellEvent {
  final AuthState authState;
  const ShellAuthStateChanged(this.authState);
}
