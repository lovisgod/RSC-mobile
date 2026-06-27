import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/mock/mock_user.dart';
import '../../../../core/storage/local_storage.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final LocalStorage _localStorage;

  ProfileCubit(this._localStorage) : super(ProfileState.guest());

  Future<void> loadProfile() async {
    final user = await _localStorage.getUser();
    if (user != null) {
      emit(ProfileState(
        isLoggedIn: true,
        userName: MockUser.name,
        userEmail: MockUser.email,
        userPhone: MockUser.phone,
        userInitials: MockUser.initials,
        defaultAddress: MockUser.defaultAddress,
      ));
    } else {
      emit(ProfileState.guest());
    }
  }
}
