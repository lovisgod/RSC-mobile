import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/shell/presentation/bloc/shell_bloc.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.init();

  // ── Auth — swap MockAuthRepository → AuthRepositoryImpl in Phase 4 ────────
  getIt
    ..registerLazySingleton<AuthRepository>(() => MockAuthRepository())
    ..registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()))
    ..registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(getIt<AuthRepository>()))
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        loginUseCase: getIt<LoginUseCase>(),
        registerUseCase: getIt<RegisterUseCase>(),
        storage: getIt<FlutterSecureStorage>(),
      ),
    )
    ..registerLazySingleton<ShellBloc>(() => ShellBloc(getIt<AuthBloc>()));
}
