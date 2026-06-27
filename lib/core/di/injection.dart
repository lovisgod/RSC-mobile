import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/checkout/presentation/cubit/checkout_cubit.dart';
import '../../features/checkout/presentation/cubit/payment_cubit.dart';
import '../../features/profile/presentation/cubit/order_history_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/track/presentation/cubit/track_cubit.dart';
import '../../features/home/data/repositories/mock_home_repository.dart';
import '../../features/search/data/repositories/mock_search_repository.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_items_usecase.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_outlet_menu_usecase.dart';
import '../../features/home/domain/usecases/get_outlets_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/outlet_detail_bloc.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
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
    )
    ..registerLazySingleton<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<ResendOtpUseCase>(
      () => ResendOtpUseCase(getIt<AuthRepository>()),
    );

  // ── BLoCs ──────────────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        registerUseCase: getIt<RegisterUseCase>(),
        verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
        loginUseCase: getIt<LoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
        resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
        changePasswordUseCase: getIt<ChangePasswordUseCase>(),
        resendOtpUseCase: getIt<ResendOtpUseCase>(),
        localStorage: getIt<LocalStorage>(),
        cookieJar: getIt<PersistCookieJar>(),
      ),
    )
    ..registerLazySingleton<ShellBloc>(() => ShellBloc(getIt<AuthBloc>()))
    ..registerLazySingleton<ProfileCubit>(
      () => ProfileCubit(getIt<LocalStorage>()),
    );

  // ── Home feature ───────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<HomeRepository>(() => const MockHomeRepository())
    ..registerLazySingleton<GetOutletsUseCase>(
      () => GetOutletsUseCase(getIt<HomeRepository>()),
    )
    ..registerLazySingleton<GetOutletMenuUseCase>(
      () => GetOutletMenuUseCase(getIt<HomeRepository>()),
    )
    ..registerLazySingleton<HomeBloc>(
      () => HomeBloc(getIt<GetOutletsUseCase>()),
    )
    ..registerFactory<OutletDetailBloc>(
      () => OutletDetailBloc(getIt<GetOutletMenuUseCase>()),
    )
    ..registerLazySingleton<CartCubit>(() => CartCubit());

  // ── Search feature ─────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<SearchRepository>(
      () => const MockSearchRepository(),
    )
    ..registerLazySingleton<SearchItemsUseCase>(
      () => SearchItemsUseCase(getIt<SearchRepository>()),
    )
    ..registerFactory<SearchBloc>(
      () => SearchBloc(getIt<SearchItemsUseCase>()),
    );

  // ── Order history ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<OrderHistoryCubit>(
    () => OrderHistoryCubit()..init(),
  );

  // ── Track feature ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<TrackCubit>(
    () => TrackCubit(getIt<OrderHistoryCubit>()),
  );

  // ── Checkout feature ────────────────────────────────────────────────────────
  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(getIt<LocalStorage>()),
  );
  getIt.registerFactory<PaymentCubit>(() => PaymentCubit());
}
