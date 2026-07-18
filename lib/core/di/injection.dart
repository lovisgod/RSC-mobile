import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/models/hive/cart_item_hive_model.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/checkout/data/repositories/address_validation_repository_impl.dart';
import '../../features/checkout/data/repositories/payment_repository_impl.dart';
import '../../features/checkout/data/repositories/preparation_suggestions_repository_impl.dart';
import '../../features/checkout/domain/repositories/address_validation_repository.dart';
import '../../features/checkout/domain/repositories/payment_repository.dart';
import '../../features/checkout/domain/repositories/preparation_suggestions_repository.dart';
import '../../features/checkout/domain/services/pending_reorder_holder.dart';
import '../../features/checkout/domain/usecases/build_payment_payload_usecase.dart';
import '../../features/checkout/domain/usecases/get_preparation_suggestions_usecase.dart';
import '../../features/checkout/domain/usecases/get_platform_charges_usecase.dart';
import '../../features/checkout/domain/usecases/initiate_payment_usecase.dart';
import '../../features/checkout/domain/usecases/retry_payment_usecase.dart';
import '../../features/checkout/domain/usecases/validate_address_usecase.dart';
import '../../features/checkout/domain/usecases/verify_payment_usecase.dart';
import '../../features/checkout/presentation/cubit/checkout_cubit.dart';
import '../../features/checkout/presentation/cubit/payment_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/address_repository_impl.dart';
import '../../features/profile/data/repositories/order_repository_impl.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/data/repositories/rating_repository_impl.dart';
import '../../features/profile/data/repositories/refund_repository_impl.dart';
import '../../features/profile/domain/repositories/address_repository.dart';
import '../../features/profile/domain/repositories/order_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/repositories/rating_repository.dart';
import '../../features/profile/domain/repositories/refund_repository.dart';
import '../../features/profile/domain/usecases/create_address_usecase.dart';
import '../../features/profile/domain/usecases/deactivate_account_usecase.dart';
import '../../features/profile/domain/usecases/delete_address_usecase.dart';
import '../../features/profile/domain/usecases/get_addresses_usecase.dart';
import '../../features/profile/domain/usecases/get_order_by_id_usecase.dart';
import '../../features/profile/domain/usecases/get_orders_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_reorder_details_usecase.dart';
import '../../features/profile/domain/usecases/rate_menu_item_usecase.dart';
import '../../features/profile/domain/usecases/reorder_usecase.dart';
import '../../features/profile/domain/usecases/request_refund_usecase.dart';
import '../../features/profile/domain/usecases/set_default_address_usecase.dart';
import '../../features/profile/domain/usecases/update_address_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_avatar_usecase.dart';
import '../../features/profile/domain/usecases/verify_profile_change_usecase.dart';
import '../../features/profile/presentation/cubit/address_cubit.dart';
import '../../features/profile/presentation/cubit/order_history_cubit.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/cubit/rating_cubit.dart';
import '../../features/track/domain/usecases/get_rider_location_usecase.dart';
import '../../features/track/presentation/cubit/track_cubit.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_items_usecase.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_outlet_menu_usecase.dart';
import '../../features/home/domain/usecases/get_outlets_usecase.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/bloc/outlet_detail_bloc.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notification_preferences_usecase.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/domain/usecases/update_notification_preferences_usecase.dart';
import '../../features/notifications/presentation/cubit/notification_preferences_cubit.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
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
import '../../main.dart';
import '../network/dio_client.dart';
import '../network/session_interceptor.dart';
import '../router/app_router.dart';
import '../services/address_service.dart';
import '../services/notification_service.dart';
import '../services/socket_service.dart';
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

  // ── Local storage ──────────────────────────────────────────────────────────
  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorage(getIt<FlutterSecureStorage>()),
  );

  // ── Pending reorder bridge — survives the gap between a reorder
  // succeeding and the next (factory-created) CheckoutCubit picking it up ──
  getIt.registerLazySingleton<PendingReorderHolder>(
    () => PendingReorderHolder(),
  );

  // ── Router — registered so SessionInterceptor can navigate on 401 without
  // a BuildContext ─────────────────────────────────────────────────────────
  getIt.registerSingleton<GoRouter>(appRouter);

  // ── Cookie-based HTTP auth ─────────────────────────────────────────────────
  final dir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage('${dir.path}/.cookies/'),
  );
  getIt.registerLazySingleton<PersistCookieJar>(() => cookieJar);
  getIt.registerLazySingleton<SessionInterceptor>(
    () => SessionInterceptor(
      cookieJar: getIt<PersistCookieJar>(),
      localStorage: getIt<LocalStorage>(),
      scaffoldMessengerKey: scaffoldMessengerKey,
      router: getIt<GoRouter>(),
    ),
  );
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(cookieJar, getIt<SessionInterceptor>()),
  );

  // ── Push notifications ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt<DioClient>(), getIt<LocalStorage>()),
  );

  // ── Realtime socket ──────────────────────────────────────────────────────────
  getIt.registerSingleton<SocketService>(SocketService());

  // ── Auth data layer ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
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

  // ── Profile data layer ─────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
    )
    ..registerLazySingleton<GetProfileUseCase>(
      () => GetProfileUseCase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<UploadAvatarUseCase>(
      () => UploadAvatarUseCase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<VerifyProfileChangeUseCase>(
      () => VerifyProfileChangeUseCase(getIt<ProfileRepository>()),
    )
    ..registerLazySingleton<DeactivateAccountUsecase>(
      () => DeactivateAccountUsecase(getIt<ProfileRepository>()),
    );

  // ── Menu item ratings ──────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<RatingRepository>(
      () => RatingRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<RateMenuItemUsecase>(
      () => RateMenuItemUsecase(getIt<RatingRepository>()),
    )
    // Singleton — ratedItemIds must survive across screens for the whole
    // session so an item is never rated twice.
    ..registerLazySingleton<RatingCubit>(
      () => RatingCubit(getIt<RateMenuItemUsecase>()),
    );

  // ── Refund requests ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<RefundRepository>(
      () => RefundRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<RequestRefundUsecase>(
      () => RequestRefundUsecase(getIt<RefundRepository>()),
    );

  // ── Address validation (backend delivery-zone check) ────────────────────────
  getIt
    ..registerLazySingleton<AddressValidationRepository>(
      () => AddressValidationRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<ValidateAddressUseCase>(
      () => ValidateAddressUseCase(getIt<AddressValidationRepository>()),
    );

  // ── Address autocomplete/resolve (Google Places via RSC delivery API) ───────
  getIt.registerLazySingleton<AddressService>(
    () => AddressService(getIt<DioClient>()),
  );

  // ── Delivery address data layer ─────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AddressRepository>(
      () => AddressRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetAddressesUseCase>(
      () => GetAddressesUseCase(getIt<AddressRepository>()),
    )
    ..registerLazySingleton<CreateAddressUseCase>(
      () => CreateAddressUseCase(getIt<AddressRepository>()),
    )
    ..registerLazySingleton<UpdateAddressUseCase>(
      () => UpdateAddressUseCase(getIt<AddressRepository>()),
    )
    ..registerLazySingleton<DeleteAddressUseCase>(
      () => DeleteAddressUseCase(getIt<AddressRepository>()),
    )
    ..registerLazySingleton<SetDefaultAddressUseCase>(
      () => SetDefaultAddressUseCase(getIt<AddressRepository>()),
    )
    ..registerFactory<AddressCubit>(
      () => AddressCubit(
        getIt<GetAddressesUseCase>(),
        getIt<CreateAddressUseCase>(),
        getIt<UpdateAddressUseCase>(),
        getIt<DeleteAddressUseCase>(),
        getIt<SetDefaultAddressUseCase>(),
        getIt<ValidateAddressUseCase>(),
        getIt<AddressService>(),
      ),
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
      () => ProfileCubit(
        getIt<LocalStorage>(),
        getIt<GetProfileUseCase>(),
        getIt<UploadAvatarUseCase>(),
        getIt<UpdateProfileUseCase>(),
        getIt<VerifyProfileChangeUseCase>(),
        getIt<DeactivateAccountUsecase>(),
      ),
    );

  // ── Home feature ───────────────────────────────────────────────────────────
  // HomeRepositoryImpl is a singleton: it caches the outlets payload in memory
  // and is shared by home, outlet-detail, and search.
  getIt
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetOutletsUseCase>(
      () => GetOutletsUseCase(getIt<HomeRepository>()),
    )
    ..registerLazySingleton<GetOutletMenuUseCase>(
      () => GetOutletMenuUseCase(getIt<HomeRepository>()),
    )
    ..registerLazySingleton<HomeBloc>(
      () => HomeBloc(
        getIt<GetOutletsUseCase>(),
        getIt<HomeRepository>(),
        getIt<SocketService>(),
      ),
    )
    ..registerFactory<OutletDetailBloc>(
      () => OutletDetailBloc(getIt<GetOutletMenuUseCase>()),
    );

  // ── Cart feature ───────────────────────────────────────────────────────────
  // The Hive box is opened in main.dart before configureDependencies() runs,
  // so it's safe to register eagerly here.
  getIt
    ..registerSingleton<Box<CartItemHiveModel>>(
      Hive.box<CartItemHiveModel>(cartBoxName),
    )
    ..registerSingleton<CartLocalDatasource>(
      CartLocalDatasource(getIt<Box<CartItemHiveModel>>()),
    )
    ..registerSingleton<CartCubit>(CartCubit(getIt<CartLocalDatasource>()));

  // ── Search feature ─────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(getIt<HomeRepository>()),
    )
    ..registerLazySingleton<SearchItemsUseCase>(
      () => SearchItemsUseCase(getIt<SearchRepository>()),
    )
    ..registerFactory<SearchBloc>(
      () => SearchBloc(getIt<SearchItemsUseCase>()),
    );

  // ── Order history ──────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetOrdersUseCase>(
      () => GetOrdersUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<GetOrderByIdUseCase>(
      () => GetOrderByIdUseCase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<GetReorderDetailsUsecase>(
      () => GetReorderDetailsUsecase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<ReorderUseCase>(
      () => ReorderUseCase(
        getIt<GetReorderDetailsUsecase>(),
        getIt<CartCubit>(),
        getIt<HomeRepository>(),
      ),
    )
    ..registerLazySingleton<OrderHistoryCubit>(
      () => OrderHistoryCubit(
        getIt<GetOrdersUseCase>(),
        getIt<GetOrderByIdUseCase>(),
        getIt<ReorderUseCase>(),
      ),
    );

  // ── Track feature ──────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<GetRiderLocationUsecase>(
      () => GetRiderLocationUsecase(getIt<OrderRepository>()),
    )
    ..registerLazySingleton<TrackCubit>(
      () => TrackCubit(
        getIt<OrderHistoryCubit>(),
        getIt<GetOrderByIdUseCase>(),
        getIt<HomeRepository>(),
        getIt<SocketService>(),
        getIt<GetRiderLocationUsecase>(),
        getIt<LocalStorage>(),
      ),
    );

  // ── Checkout feature ────────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<BuildPaymentPayloadUseCase>(
      () => const BuildPaymentPayloadUseCase(),
    )
    ..registerLazySingleton<InitiatePaymentUseCase>(
      () => InitiatePaymentUseCase(getIt<PaymentRepository>()),
    )
    ..registerLazySingleton<GetPlatformChargesUseCase>(
      () => GetPlatformChargesUseCase(getIt<PaymentRepository>()),
    )
    ..registerLazySingleton<VerifyPaymentUseCase>(
      () => VerifyPaymentUseCase(getIt<PaymentRepository>()),
    )
    ..registerLazySingleton<RetryPaymentUseCase>(
      () => RetryPaymentUseCase(getIt<PaymentRepository>()),
    )
    ..registerLazySingleton<PreparationSuggestionsRepository>(
      () => PreparationSuggestionsRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetPreparationSuggestionsUsecase>(
      () => GetPreparationSuggestionsUsecase(
        getIt<PreparationSuggestionsRepository>(),
      ),
    )
    ..registerFactory<CheckoutCubit>(
      () => CheckoutCubit(
        getIt<LocalStorage>(),
        getIt<AddressService>(),
        getIt<ValidateAddressUseCase>(),
        getIt<GetPreparationSuggestionsUsecase>(),
        getIt<GetPlatformChargesUseCase>(),
        getIt<PendingReorderHolder>(),
      ),
    )
    ..registerFactory<PaymentCubit>(
      () => PaymentCubit(
        getIt<BuildPaymentPayloadUseCase>(),
        getIt<InitiatePaymentUseCase>(),
        getIt<GetPlatformChargesUseCase>(),
        getIt<VerifyPaymentUseCase>(),
        getIt<RetryPaymentUseCase>(),
      ),
    );

  // ── Notifications feature ───────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(getIt<DioClient>()),
    )
    ..registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(getIt<NotificationRepository>()),
    )
    ..registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(getIt<NotificationRepository>()),
    )
    ..registerLazySingleton<GetNotificationPreferencesUseCase>(
      () => GetNotificationPreferencesUseCase(getIt<NotificationRepository>()),
    )
    ..registerLazySingleton<UpdateNotificationPreferencesUseCase>(
      () =>
          UpdateNotificationPreferencesUseCase(getIt<NotificationRepository>()),
    )
    ..registerLazySingleton<NotificationsCubit>(
      () => NotificationsCubit(
        getIt<GetNotificationsUseCase>(),
        getIt<MarkNotificationReadUseCase>(),
        getIt<LocalStorage>(),
      ),
    )
    ..registerFactory<NotificationPreferencesCubit>(
      () => NotificationPreferencesCubit(
        getIt<GetNotificationPreferencesUseCase>(),
        getIt<UpdateNotificationPreferencesUseCase>(),
      ),
    );
}
