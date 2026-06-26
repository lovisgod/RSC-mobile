import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/shell/presentation/bloc/shell_bloc.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.init(); // registers FlutterSecureStorage, NetworkInfo

  // ── Cookie-based HTTP auth ─────────────────────────────────────────────────
  final dir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${dir.path}/.cookies/'),
  );
  getIt.registerLazySingleton<PersistCookieJar>(() => cookieJar);
  getIt.registerLazySingleton<DioClient>(() => DioClient(cookieJar));

  // ── Auth data layer ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );

  // ── Local storage ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorage(getIt<FlutterSecureStorage>()),
  );

  // ── Auth use cases ─────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<VerifyOtpUseCase>(
      () => VerifyOtpUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt<AuthRepository>()),
    );

  // ── BLoCs ──────────────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        registerUseCase: getIt<RegisterUseCase>(),
        verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
        loginUseCase: getIt<LoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        localStorage: getIt<LocalStorage>(),
      ),
    )
    ..registerLazySingleton<ShellBloc>(() => ShellBloc(getIt<AuthBloc>()));
}
