/// Environment configuration selected at build/run time via
/// `--dart-define=ENVIRONMENT=development|staging|production`.
///
/// All URLs in the app come from here — never hardcode a URL elsewhere.
/// Registered as a singleton in DI; access via `getIt<AppConfig>()`.
class AppConfig {
  final String environment;
  final String baseUrl;
  final String paymentRedirectBase;
  final String appName;

  const AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.paymentRedirectBase,
    required this.appName,
  });

  static const AppConfig development = AppConfig._(
    environment: 'development',
    baseUrl: 'https://api-dev.rscdev.tech',
    paymentRedirectBase: 'https://dev.rscdev.tech/tracking',
    appName: 'DineOut NG Dev',
  );

  static const AppConfig staging = AppConfig._(
    environment: 'staging',
    baseUrl: 'https://api-staging.rscdev.tech',
    paymentRedirectBase: 'https://staging.rscdev.tech/tracking',
    appName: 'DineOut NG Staging',
  );

  static const AppConfig production = AppConfig._(
    environment: 'production',
    baseUrl: 'https://api.rscdev.tech',
    paymentRedirectBase: 'https://rscdev.tech/tracking',
    appName: 'DineOut NG',
  );

  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  bool get isProduction => environment == 'production';

  /// Defaults to development so `flutter run` without `--dart-define`
  /// still works.
  static AppConfig fromEnvironment() {
    const env = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    switch (env) {
      case 'staging':
        return AppConfig.staging;
      case 'production':
        return AppConfig.production;
      default:
        return AppConfig.development;
    }
  }

  @override
  String toString() => 'AppConfig($environment: $baseUrl)';
}
