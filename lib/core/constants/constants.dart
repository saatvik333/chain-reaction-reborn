/// Core constants and configuration.
library;

export 'app_dimensions.dart';

class AppConstants {
  static const String appVersion = '1.3.0';
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://saatvik.xyz/privacy',
  );
}
